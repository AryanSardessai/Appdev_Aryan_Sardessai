import * as Google from "expo-auth-session/providers/google";
import { FirebaseRecaptchaVerifierModal } from "expo-firebase-recaptcha";
import * as WebBrowser from "expo-web-browser";
import { getApp, getApps, initializeApp } from "firebase/app";
import {
  createUserWithEmailAndPassword,
  getAuth,
  GoogleAuthProvider,
  onAuthStateChanged,
  PhoneAuthProvider,
  signInWithCredential,
  signInWithEmailAndPassword,
  signOut,
} from "firebase/auth";
import React, { useEffect, useRef, useState } from "react";
import {
  Alert,
  FlatList,
  ScrollView,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from "react-native";

WebBrowser.maybeCompleteAuthSession();

// ✅ Firebase Configuration
const firebaseConfig = {
  apiKey: "AIzaSyAsDg-G6gOFqnLpZ0fnNkAbOSopyrR0niA",
  authDomain: "appauth-ee8a5.firebaseapp.com",
  projectId: "appauth-ee8a5",
  storageBucket: "appauth-ee8a5.firebasestorage.app",
  messagingSenderId: "163395459823",
  appId: "1:163395459823:web:8a4a2298932465cdd0591a",
  measurementId: "G-4MJBQ80M1S"
};

// ✅ Initialize Firebase Safely
const app = getApps().length ? getApp() : initializeApp(firebaseConfig);
const auth = getAuth(app);

export default function FirebaseTodoApp() {
  // 🔹 States
  const [user, setUser] = useState<any | null>(null);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isLogin, setIsLogin] = useState(true);
  const [task, setTask] = useState("");
  const [tasks, setTasks] = useState<string[]>([]);
  const [authMode, setAuthMode] = useState<"email" | "google" | "phone">("email");

  // ==========================
  // GOOGLE AUTH SETUP
  // ==========================
  const [request, response, promptAsync] = Google.useAuthRequest({
    webClientId: "163395459823-ikl8rcjmt0n85pobt0o0dk3dqo9jovfj.apps.googleusercontent.com",
  });

  useEffect(() => {
    if (response?.type === "success") {
      const { id_token } = response.params;
      const credential = GoogleAuthProvider.credential(id_token);
      signInWithCredential(auth, credential);
    }
  }, [response]);

  // ==========================
  // AUTH STATE OBSERVER
  // ==========================
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      setUser(currentUser);
    });
    return unsubscribe;
  }, []);

  // ==========================
  // PHONE AUTH SETUP
  // ==========================
  const recaptchaVerifier = useRef<FirebaseRecaptchaVerifierModal>(null);
  const [phoneNumber, setPhoneNumber] = useState("");
  const [verificationId, setVerificationId] = useState<string | null>(null);
  const [otp, setOtp] = useState("");

  // Send OTP
  const sendVerification = async () => {
    if (!phoneNumber.startsWith("+")) {
      Alert.alert("Error", "Please include country code (e.g. +91)");
      return;
    }
    try {
      const provider = new PhoneAuthProvider(auth);
      const id = await provider.verifyPhoneNumber(
        phoneNumber,
        recaptchaVerifier.current!
      );
      setVerificationId(id);
      Alert.alert("OTP sent", "Check your SMS for the verification code.");
    } catch (err: any) {
      Alert.alert("Error", err.message);
    }
  };

  // Confirm OTP
  const confirmCode = async () => {
    try {
      if (!verificationId) throw new Error("No verification ID found.");
      const credential = PhoneAuthProvider.credential(verificationId, otp);
      await signInWithCredential(auth, credential);
      setVerificationId(null);
      setOtp("");
    } catch (err: any) {
      Alert.alert("Invalid OTP", err.message);
    }
  };

  // ==========================
  // EMAIL/PASSWORD AUTH
  // ==========================
  const handleAuth = async () => {
    try {
      if (isLogin) {
        await signInWithEmailAndPassword(auth, email, password);
      } else {
        await createUserWithEmailAndPassword(auth, email, password);
        Alert.alert("Success", "Account created!");
      }
    } catch (error: any) {
      Alert.alert("Error", error.message);
    }
  };

  const handleLogout = async () => {
    await signOut(auth);
  };

  // ==========================
  // TODO LIST
  // ==========================
  const addTask = () => {
    if (task.trim() === "") return;
    setTasks([...tasks, task]);
    setTask("");
  };

  // ==================================================
  // AUTH SCREENS
  // ==================================================
  if (!user) {
    return (
      <ScrollView
        contentContainerStyle={{ flexGrow: 1, justifyContent: "center", padding: 20 }}
      >
        <Text
          style={{
            fontSize: 26,
            textAlign: "center",
            fontWeight: "bold",
            marginBottom: 20,
          }}
        >
          {authMode === "email"
            ? isLogin
              ? "Email Login"
              : "Email Signup"
            : authMode === "google"
            ? "Google Login"
            : "Phone Login"}
        </Text>

        {/* EMAIL LOGIN/SIGNUP */}
        {authMode === "email" && (
          <>
            <TextInput
              placeholder="Email"
              value={email}
              onChangeText={setEmail}
              autoCapitalize="none"
              keyboardType="email-address"
              style={inputStyle}
            />
            <TextInput
              placeholder="Password"
              value={password}
              secureTextEntry
              onChangeText={setPassword}
              style={inputStyle}
            />

            <TouchableOpacity style={buttonStyle("#6f42c1")} onPress={handleAuth}>
              <Text style={buttonTextStyle}>
                {isLogin ? "Login" : "Sign Up"}
              </Text>
            </TouchableOpacity>

            <TouchableOpacity onPress={() => setIsLogin(!isLogin)}>
              <Text style={linkText}>
                {isLogin
                  ? "Don’t have an account? Sign up"
                  : "Already have an account? Login"}
              </Text>
            </TouchableOpacity>
          </>
        )}

        {/* GOOGLE LOGIN */}
        {authMode === "google" && (
          <TouchableOpacity
            onPress={() => promptAsync()}
            style={buttonStyle("#DB4437")}
          >
            <Text style={buttonTextStyle}>Sign in with Google</Text>
          </TouchableOpacity>
        )}

        {/* PHONE LOGIN */}
        {authMode === "phone" && (
          <>
            <FirebaseRecaptchaVerifierModal
              ref={recaptchaVerifier}
              firebaseConfig={app.options}
            />
            <TextInput
              placeholder="+91 9876543210"
              keyboardType="phone-pad"
              value={phoneNumber}
              onChangeText={setPhoneNumber}
              style={inputStyle}
            />
            {!verificationId ? (
              <TouchableOpacity
                onPress={sendVerification}
                style={buttonStyle("#6f42c1")}
              >
                <Text style={buttonTextStyle}>Send OTP</Text>
              </TouchableOpacity>
            ) : (
              <>
                <TextInput
                  placeholder="Enter OTP"
                  keyboardType="numeric"
                  value={otp}
                  onChangeText={setOtp}
                  style={inputStyle}
                />
                <TouchableOpacity
                  onPress={confirmCode}
                  style={buttonStyle("#28a745")}
                >
                  <Text style={buttonTextStyle}>Verify OTP</Text>
                </TouchableOpacity>
              </>
            )}
          </>
        )}

        {/* AUTH MODE TOGGLE */}
        <View
          style={{
            flexDirection: "row",
            justifyContent: "space-around",
            marginTop: 25,
          }}
        >
          <TouchableOpacity onPress={() => setAuthMode("email")}>
            <Text style={{ color: authMode === "email" ? "#6f42c1" : "#555" }}>
              Email
            </Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={() => setAuthMode("google")}>
            <Text style={{ color: authMode === "google" ? "#6f42c1" : "#555" }}>
              Google
            </Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={() => setAuthMode("phone")}>
            <Text style={{ color: authMode === "phone" ? "#6f42c1" : "#555" }}>
              Phone
            </Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    );
  }

  // ==================================================
  // PROTECTED DASHBOARD
  // ==================================================
  return (
    <View style={{ flex: 1, padding: 20 }}>
      <View
        style={{
          flexDirection: "row",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: 20,
        }}
      >
        <Text style={{ fontSize: 20, fontWeight: "bold" }}>
          Welcome, {user.email || user.phoneNumber || "User"}
        </Text>
        <TouchableOpacity onPress={handleLogout}>
          <Text style={{ color: "red" }}>Logout</Text>
        </TouchableOpacity>
      </View>

      <TextInput
        placeholder="Enter new task"
        value={task}
        onChangeText={setTask}
        style={inputStyle}
      />
      <TouchableOpacity
        onPress={addTask}
        style={buttonStyle("#6f42c1")}
      >
        <Text style={buttonTextStyle}>Add Task</Text>
      </TouchableOpacity>

      <FlatList
        data={tasks}
        keyExtractor={(_, index) => index.toString()}
        renderItem={({ item }) => (
          <View
            style={{
              padding: 10,
              borderBottomWidth: 1,
              borderColor: "#ccc",
            }}
          >
            <Text>{item}</Text>
          </View>
        )}
      />
    </View>
  );
}

// ==================================================
// STYLES
// ==================================================
const inputStyle = {
  borderWidth: 1,
  borderColor: "#aaa",
  padding: 10,
  borderRadius: 6,
  marginBottom: 10,
};

const buttonStyle = (color: string) => ({
  backgroundColor: color,
  padding: 12,
  borderRadius: 6,
  marginVertical: 5,
});

const buttonTextStyle = {
  color: "white",
  textAlign: "center" as const,
  fontSize: 16,
};

const linkText = {
  textAlign: "center" as const,
  color: "#007bff",
  marginTop: 10,
};
