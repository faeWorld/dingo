import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Import feature screens
import 'pages/home.dart';
import 'pages/signup.dart';
import 'pages/login.dart';
import 'pages/dashboard.dart';
import 'pages/alerts.dart';
import 'pages/checkup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skin Disease Analysis Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/sign_up': (context) => const SignUpScreen(),
        '/sign_in': (context) => const SignInScreen(),
        '/alerts': (context) => const AlertPage(),
        '/scanme': (context) => const ScanMeButton(),
        '/dashboard': (context) => const Dashboard(),
      },
    );
  }
}
