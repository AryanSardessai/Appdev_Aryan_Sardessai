import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:math_expressions/math_expressions.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}


// Root widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}

// Auth Observer (controls navigation)
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return WelcomeScreen();
        }
      },
    );
  }
}

// -------------------- SCREENS --------------------

// Welcome screen
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children: [
              OutlinedButton(
  onPressed: () => Navigator.push(
      context, MaterialPageRoute(builder: (_) => PhoneAuthScreen())),
  child: Text("Sign in with Phone"),
),

              ElevatedButton.icon(
  icon: Icon(Icons.login),
  label: Text("Sign in with Google"),
  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
  onPressed: () async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User cancelled
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Google sign-in failed: $e")));
    }
  },
),

              Icon(Icons.lock_outline, size: 100, color: Colors.deepPurple),
              SizedBox(height: 20),
              Text("Welcome to Firebase Auth Demo",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: Text("Login"),
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SignupScreen()),
                  );
                },
                child: Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneAuthScreen extends StatefulWidget {
  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  String verificationId = '';
  bool codeSent = false;

  Future<void> verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  Future<void> verifyOTP() async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone Verification")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (!codeSent) ...[
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone number (+91...)",
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: verifyPhone, child: Text("Send OTP")),
            ] else ...[
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: "Enter OTP",
                  prefixIcon: Icon(Icons.message),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: verifyOTP, child: Text("Verify OTP")),
            ],
          ],
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String? errorMessage;

  Future<void> login() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration:
              InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration:
              InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)),
            ),
            SizedBox(height: 20),
            if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),
            loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: Text("Login")),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ResetPasswordScreen()),
                );
              },
              child: Text("Forgot Password?"),
            ),
          ],
        ),
      ),
    );
  }
}

// Signup Screen
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String? errorMessage;

  Future<void> signup() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration:
              InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration:
              InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)),
            ),
            SizedBox(height: 20),
            if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),
            loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: signup, child: Text("Sign Up")),
          ],
        ),
      ),
    );
  }
}

// Reset Password Screen
class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  String? message;

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      setState(() => message = "Password reset email sent!");
    } on FirebaseAuthException catch (e) {
      setState(() => message = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration:
              InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: resetPassword, child: Text("Send Reset Email")),
            if (message != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(message!, style: TextStyle(color: Colors.green)),
              ),
          ],
        ),
      ),
    );
  }
}

// Home Screen (Protected)
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String display = "";
  String result = "";
  

  void buttonPressed(String value) {
    setState(() {
      if (value == "C") {
        display = "";
        result = "";
      } else if (value == "=") {
        try {
          // Simple expression evaluator using Dart
          result = evaluate(display);
        } catch (e) {
          result = "Error";
        }
      } else {
        display += value;
      }
    });
  }

  String evaluate(String expression) {
  try {
    expression = expression.replaceAll('×', '*').replaceAll('÷', '/');
    Parser p = Parser();
    Expression exp = p.parse(expression);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);
    return eval.toString();
  } catch (e) {
    return "Invalid";
  }
}


  @override
  Widget build(BuildContext context) {
    final buttons = [
      '7', '8', '9', '/',
      '4', '5', '6', '*',
      '1', '2', '3', '-',
      '0', '.', 'C', '+',
      '='
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Home Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(Icons.account_circle, size: 80, color: Colors.deepPurple),
                  Text(
                    "Welcome, ${user?.email ?? user?.phoneNumber ?? 'User'}",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // CALCULATOR
            Expanded(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      display,
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      result.isNotEmpty ? "Result: $result" : "",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      itemCount: buttons.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final value = buttons[index];
                        return ElevatedButton(
                          onPressed: () => buttonPressed(value),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: value == '='
                                ? Colors.deepPurple
                                : Colors.deepPurple.shade100,
                          ),
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 22,
                              color: value == '=' ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Profile Screen
class ProfileScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text("Display Name: ${user?.displayName ?? 'N/A'}",
                style: TextStyle(fontSize: 18)),
            Text("Email: ${user?.email ?? 'N/A'}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
