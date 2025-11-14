// FULL Yoga App - Auth + Google + Phone OTP + Firestore Favs + Cached API + Want More


import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Your Firebase config file
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const YogaApp());
}

class YogaApp extends StatelessWidget {
  const YogaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Yoga App",
      theme: ThemeData(primarySwatch: Colors.purple),
      debugShowCheckedModeBanner: false,
      home: const RootPage(),
    );
  }
}

// ------------------ ROOT ------------------
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snap.data == null ? const AuthSwitcher() : HomeScreen(user: snap.data!);
      },
    );
  }
}

// ------------------ AUTH SWITCHER ------------------
class AuthSwitcher extends StatefulWidget {
  const AuthSwitcher({super.key});

  @override
  State<AuthSwitcher> createState() => _AuthSwitcherState();
}

class _AuthSwitcherState extends State<AuthSwitcher> {
  bool showLogin = true;
  bool showPhone = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yoga App Authentication"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              setState(() {
                if (v == "login") { showLogin = true; showPhone = false; }
                if (v == "register") { showLogin = false; showPhone = false; }
                if (v == "phone") { showPhone = true; }
              });
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "login", child: Text("Login")),
              PopupMenuItem(value: "register", child: Text("Register")),
              PopupMenuItem(value: "phone", child: Text("Phone OTP")),
            ],
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: showPhone
                ? const PhoneAuthWidget()
                : showLogin
                    ? const LoginWidget()
                    : const RegisterWidget(),
          ),
        ),
      ),
    );
  }
}

// ------------------ LOGIN ------------------
class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: pass.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    }
    setState(() => loading = false);
  }

  Future<void> googleLogin() async {
    try {
      final google = GoogleSignIn();
      final acc = await google.signIn();
      if (acc == null) return;

      final auth = await acc.authentication;
      final cred = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );

      await FirebaseAuth.instance.signInWithCredential(cred);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Sign-in Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return authCard([
      const Text("Login", style: TextStyle(fontSize: 24)),
      TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
      TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: loading ? null : login,
        child: loading ? const CircularProgressIndicator() : const Text("Login"),
      ),
      OutlinedButton.icon(
        onPressed: googleLogin,
        icon: const Icon(Icons.login),
        label: const Text("Sign in with Google"),
      ),
    ]);
  }
}

// ------------------ REGISTER ------------------
class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;

  Future<void> register() async {
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: pass.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Register failed: $e")));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return authCard([
      const Text("Register", style: TextStyle(fontSize: 24)),
      TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
      TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: loading ? null : register,
        child: loading ? const CircularProgressIndicator() : const Text("Create Account"),
      ),
    ]);
  }
}

// ------------------ PHONE OTP ------------------
class PhoneAuthWidget extends StatefulWidget {
  const PhoneAuthWidget({super.key});

  @override
  State<PhoneAuthWidget> createState() => _PhoneAuthWidgetState();
}

class _PhoneAuthWidgetState extends State<PhoneAuthWidget> {
  final phone = TextEditingController();
  final otp = TextEditingController();
  String? verificationId;
  bool codeSent = false;

  Future<void> sendOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone.text.trim(),
      verificationCompleted: (cred) async {
        await FirebaseAuth.instance.signInWithCredential(cred);
      },
      verificationFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: ${e.message}")));
      },
      codeSent: (id, _) {
        verificationId = id;
        setState(() => codeSent = true);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> verifyOtp() async {
    final cred = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otp.text.trim(),
    );
    await FirebaseAuth.instance.signInWithCredential(cred);
  }

  @override
  Widget build(BuildContext context) {
    return authCard([
      const Text("Phone Authentication", style: TextStyle(fontSize: 24)),
      TextField(controller: phone, decoration: const InputDecoration(labelText: "Phone (e.g. +123456789)")),
      ElevatedButton(onPressed: sendOtp, child: const Text("Send OTP")),
      if (codeSent) ...[
        TextField(controller: otp, decoration: const InputDecoration(labelText: "Enter OTP")),
        ElevatedButton(onPressed: verifyOtp, child: const Text("Verify OTP")),
      ]
    ]);
  }
}

// ------------------ CARD WRAPPER ------------------
Widget authCard(List<Widget> widgets) {
  return Card(
    elevation: 6,
    margin: const EdgeInsets.all(24),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: widgets),
    ),
  );
}

// ---------------- POSE MODEL (robust) ----------------
class Pose {
  final String id;
  final String name;
  final String description; // we populate from pose_benefits / description / other keys
  final String difficulty;  // derived heuristically

  Pose({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
  });

  /// Robust factory that checks several possible fields the API might send.
  factory Pose.fromJson(Map<String, dynamic> e) {
    // ID
    final id = (e['id'] ?? e['_id'] ?? '').toString();

    // Name: try different common fields
    final name = (e['english_name'] ??
        e['name'] ??
        e['asana'] ??
        e['pose_name'] ??
        'Unknown')
        .toString();

    // Gather possible sources of description/benefits/steps
    String desc = '';

    // Case 1: pose_benefits (array of strings)
    dynamic benefits = e['pose_benefits'] ?? e['benefits'] ?? e['benefit'];
    if (benefits != null) {
      if (benefits is List) {
        // filter nulls & convert to strings
        final list = benefits.where((x) => x != null).map((x) => x.toString()).toList();
        if (list.isNotEmpty) {
          desc = list.join('\n• ');
        }
      } else if (benefits is String) {
        desc = benefits;
      }
    }

    // Case 2: explicit description field
    if ((desc.isEmpty) && (e['description'] != null)) {
      desc = e['description'].toString();
    }

    // Case 3: other fields that sometimes include text
    if (desc.isEmpty && e['details'] != null) {
      desc = e['details'].toString();
    }

    // Case 4: steps/instructions arrays -> join them
    if (desc.isEmpty && (e['steps'] is List || e['instructions'] is List)) {
      final steps = (e['steps'] ?? e['instructions']) as List<dynamic>?;
      if (steps != null) {
        final list = steps.where((x) => x != null).map((x) => x.toString()).toList();
        if (list.isNotEmpty) desc = list.join('\n');
      }
    }

    // Final fallback
    if (desc.isEmpty) desc = 'No description available.';

    // Heuristic difficulty: based on number of benefits (if present)
    String difficulty = '';
    try {
      final countBenefits = (e['pose_benefits'] is List) ? (e['pose_benefits'] as List).length : 0;
      if (countBenefits == 0) difficulty = '';
      else if (countBenefits <= 2) difficulty = 'Beginner';
      else if (countBenefits <= 4) difficulty = 'Intermediate';
      else difficulty = 'Advanced';
    } catch (_) {
      difficulty = '';
    }

    return Pose(
      id: id,
      name: name,
      description: desc,
      difficulty: (e['difficulty']?.toString() ?? difficulty),
    );
  }
}



// ------------------ HOME SCREEN ------------------
class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Pose>> posesFuture;
  List<Pose> allPoses = [];
  Set<String> favs = {};
  int showCount = 10;
  String tab = "all";

  @override
  void initState() {
    super.initState();
    posesFuture = loadPoses();
    loadFavs();
  }

  // ---------- Load Poses With Cache ----------
  Future<List<Pose>> loadPoses() async {
    final prefs = await SharedPreferences.getInstance();
    final cache = prefs.getString("poseCache");

    if (cache != null) {
      final data = json.decode(cache) as List;
      allPoses = data.map((e) => Pose.fromJson(e)).toList();
      return allPoses;
    }

    try {
      final res = await http
          .get(Uri.parse("https://yoga-api-nzy4.onrender.com/v1/poses"))
          .timeout(const Duration(seconds: 4));

      final List list = json.decode(res.body);
      await prefs.setString("poseCache", json.encode(list));
      allPoses = list.map((e) => Pose.fromJson(e)).toList();
      return allPoses;
    } catch (e) {
      return [];
    }
  }

  // ---------- Load Favs ----------
  Future<void> loadFavs() async {
    final uid = widget.user.uid;
    final doc = await FirebaseFirestore.instance.collection("favorites").doc(uid).get();
    if (doc.exists) {
      favs = Set<String>.from(doc["poses"]);
    }
    setState(() {});
  }

  // ---------- Save Favs ----------
  Future<void> saveFavs() async {
    final uid = widget.user.uid;
    await FirebaseFirestore.instance.collection("favorites").doc(uid).set({
      "poses": favs.toList(),
    });
  }

  // ---------- Build Pose Card ----------
  Widget poseCard(Pose p) {
    final fav = favs.contains(p.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text(p.name),
        subtitle: Text(p.difficulty),
        trailing: IconButton(
          icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
              color: fav ? Colors.red : null),
          onPressed: () {
            setState(() {
              fav ? favs.remove(p.id) : favs.add(p.id);
            });
            saveFavs();
          },
        ),
        onTap: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(p.name),
            content: Text(p.description),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Profile ----------
  Widget profile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.user.email ?? "Phone User", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  // ---------- MAIN UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yoga — ${tab == 'all' ? "All Poses" : tab == 'fav' ? "Favourites" : "Profile"}")),
      body: FutureBuilder(
        future: posesFuture,
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final poses = tab == "fav"
              ? allPoses.where((p) => favs.contains(p.id)).toList()
              : allPoses.take(showCount).toList();

          if (tab == "profile") return profile();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: poses.map(poseCard).toList(),
                ),
              ),
              if (tab == "all" && showCount < allPoses.length)
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: ElevatedButton(
                    onPressed: () => setState(() => showCount += 5),
                    child: const Text("Want More"),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab == "all" ? 0 : tab == "fav" ? 1 : 2,
        onTap: (i) {
          setState(() {
            tab = i == 0 ? "all" : i == 1 ? "fav" : "profile";
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "All"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Fav"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
