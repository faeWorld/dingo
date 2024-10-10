import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard.dart'; // Your dashboard screen
import 'signup.dart'; // Import your signup screen

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoggingIn = false;
  String? _errorMessage; // Variable to hold error messages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Center the content
                children: [
                  // Welcome message
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20.0, top: 40.0),
                    child: Column(
                      children: [
                        Text(
                          "Welcome Back to",
                          style: TextStyle(
                            fontFamily: 'DreamCottage',
                            fontSize: 20,
                            color: Color.fromARGB(255, 35, 34, 34),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "ERMO",
                          style: TextStyle(
                            fontFamily: 'Frista',
                            fontSize: 30,
                            color: Color.fromARGB(255, 35, 34, 34),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Add the image above the email field
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Image.asset(
                      'assets/images/ermo.webp', // Correct path to your image
                      height: 100, // Adjust height as needed
                      fit: BoxFit.contain, // Maintain the aspect ratio
                    ),
                  ),

                  // Display error message if exists
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 4, 36, 59)),
                      ),
                    ),

                  // Email TextField
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25.0),
                    child: SizedBox(
                      width: 300,
                      height: 55,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          filled: true,
                          fillColor: const Color(0xFFFCEBEB),
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 35, 34, 34),
                            fontFamily: 'DreamCottage',
                            fontSize: 16,
                          ),
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 91, 90, 90),
                            fontFamily: 'DreamCottage',
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  // Password TextField
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: SizedBox(
                      width: 300,
                      height: 55,
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: const Color(0xFFFCEBEB),
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 51, 51, 51),
                            fontFamily: 'DreamCottage',
                            fontSize: 16,
                          ),
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 97, 97, 97),
                            fontFamily: 'DreamCottage',
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Space after password field
                  // Log In Button
                  ElevatedButton(
                    onPressed: _isLoggingIn ? null : _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50), // Button size
                      backgroundColor: const Color.fromARGB(255, 88, 0, 45),
                      foregroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'DreamCottage',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _isLoggingIn
                        ? const CircularProgressIndicator()
                        : const Text('Log In'),
                  ),
                  const SizedBox(height: 20), // Space after button
                  // Gesture for Sign Up
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) =>
                                const SignUpScreen()), // Navigate to sign-up screen
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        color: Color.fromARGB(255, 36, 36, 36),
                        fontSize: 16,
                        fontFamily: 'DreamCottage',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState?.validate() == true) {
      setState(() {
        _isLoggingIn = true;
        _errorMessage = null; // Reset error message
      });

      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      } catch (e) {
        setState(() {
          _isLoggingIn = false;
          _errorMessage =
              'Login failed. Please check your credentials.'; // Set error message
        });
        print('Error during login: $e');
      }
    }
  }
}
