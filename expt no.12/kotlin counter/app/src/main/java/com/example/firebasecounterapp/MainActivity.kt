package com.example.firebasecounterapp

import android.app.Activity
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.firebasecounterapp.ui.theme.FirebaseCounterAppTheme
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.firebase.FirebaseException
import com.google.firebase.auth.*
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase
import java.util.concurrent.TimeUnit

class MainActivity : ComponentActivity() {

    private lateinit var auth: FirebaseAuth
    private lateinit var googleSignInClient: GoogleSignInClient

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        auth = Firebase.auth

        // Configure Google Sign-In
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken("163395459823-ikl8rcjmt0n85pobt0o0dk3dqo9jovfj.apps.googleusercontent.com")
            .requestEmail()
            .build()
        googleSignInClient = GoogleSignIn.getClient(this, gso)

        setContent {
            FirebaseCounterAppTheme {
                var user by remember { mutableStateOf(auth.currentUser) }

                Surface(modifier = Modifier.fillMaxSize()) {
                    if (user == null) {
                        AuthScreen(
                            auth = auth,
                            googleSignInClient = googleSignInClient,
                            onLoginSuccess = { user = auth.currentUser }
                        )
                    } else {
                        CounterScreen(
                            onLogout = {
                                auth.signOut()
                                googleSignInClient.signOut()
                                user = null
                            }
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun AuthScreen(
    auth: FirebaseAuth,
    googleSignInClient: GoogleSignInClient,
    onLoginSuccess: () -> Unit
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var phone by remember { mutableStateOf("") }
    var otp by remember { mutableStateOf("") }
    var verificationId by remember { mutableStateOf<String?>(null) }
    var isOtpSent by remember { mutableStateOf(false) }

    val context = LocalContext.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("Firebase Login", fontSize = 26.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(20.dp))

        // Email login/signup
        OutlinedTextField(
            value = email, onValueChange = { email = it },
            label = { Text("Email") }, modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(10.dp))
        OutlinedTextField(
            value = password, onValueChange = { password = it },
            label = { Text("Password") },
            visualTransformation = PasswordVisualTransformation(),
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(10.dp))
        Button(
            onClick = {
                auth.signInWithEmailAndPassword(email, password)
                    .addOnSuccessListener { onLoginSuccess() }
                    .addOnFailureListener {
                        // If user doesn’t exist, create one
                        auth.createUserWithEmailAndPassword(email, password)
                            .addOnSuccessListener { onLoginSuccess() }
                            .addOnFailureListener { e ->
                                Toast.makeText(context, e.message, Toast.LENGTH_SHORT).show()
                            }
                    }
            },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Login / Signup with Email")
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Google Sign-In (just intent launch)
        Button(
            onClick = {
                val intent = googleSignInClient.signInIntent
                (context as Activity).startActivityForResult(intent, 9001)
            },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(MaterialTheme.colorScheme.secondary)
        ) {
            Text("Sign in with Google")
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Phone Auth Section
        OutlinedTextField(
            value = phone, onValueChange = { phone = it },
            label = { Text("Phone (+91...)") }, modifier = Modifier.fillMaxWidth()
        )
        if (isOtpSent) {
            Spacer(modifier = Modifier.height(10.dp))
            OutlinedTextField(
                value = otp, onValueChange = { otp = it },
                label = { Text("Enter OTP") }, modifier = Modifier.fillMaxWidth()
            )
        }

        Spacer(modifier = Modifier.height(10.dp))

        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Button(
                onClick = {
                    if (phone.isBlank()) {
                        Toast.makeText(context, "Enter phone number", Toast.LENGTH_SHORT).show()
                        return@Button
                    }

                    val options = PhoneAuthOptions.newBuilder(auth)
                        .setPhoneNumber(phone)
                        .setTimeout(60L, TimeUnit.SECONDS)
                        .setActivity(context as Activity)
                        .setCallbacks(object : PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
                            override fun onVerificationCompleted(credential: PhoneAuthCredential) {
                                auth.signInWithCredential(credential)
                                    .addOnSuccessListener { onLoginSuccess() }
                                    .addOnFailureListener {
                                        Toast.makeText(context, it.message, Toast.LENGTH_SHORT).show()
                                    }
                            }

                            override fun onVerificationFailed(e: FirebaseException) {
                                Toast.makeText(context, "Failed: ${e.message}", Toast.LENGTH_SHORT).show()
                            }

                            override fun onCodeSent(
                                vid: String,
                                token: PhoneAuthProvider.ForceResendingToken
                            ) {
                                super.onCodeSent(vid, token)
                                verificationId = vid
                                isOtpSent = true
                                Toast.makeText(context, "OTP Sent!", Toast.LENGTH_SHORT).show()
                            }
                        })
                        .build()

                    PhoneAuthProvider.verifyPhoneNumber(options)
                },
                modifier = Modifier.weight(1f)
            ) {
                Text("Send OTP")
            }

            if (isOtpSent) {
                Button(
                    onClick = {
                        if (otp.isBlank()) {
                            Toast.makeText(context, "Enter OTP first", Toast.LENGTH_SHORT).show()
                            return@Button
                        }

                        verificationId?.let {
                            val credential = PhoneAuthProvider.getCredential(it, otp)
                            auth.signInWithCredential(credential)
                                .addOnSuccessListener { onLoginSuccess() }
                                .addOnFailureListener { e ->
                                    Toast.makeText(context, e.message, Toast.LENGTH_SHORT).show()
                                }
                        }
                    },
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Verify OTP")
                }
            }
        }
    }
}

@Composable
fun CounterScreen(onLogout: () -> Unit) {
    var count by remember { mutableStateOf(0) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("Counter App", fontSize = 30.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(20.dp))
        Text(text = "$count", fontSize = 60.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(20.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(15.dp)) {
            Button(onClick = { count++ }) { Text("+") }
            Button(onClick = { count-- }) { Text("-") }
        }
        Spacer(modifier = Modifier.height(25.dp))
        Button(onClick = { count = 0 }) { Text("Reset") }
        Spacer(modifier = Modifier.height(25.dp))
        Button(onClick = onLogout, colors = ButtonDefaults.buttonColors(MaterialTheme.colorScheme.error)) {
            Text("Logout")
        }
    }
}
