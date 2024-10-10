import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'dashboard.dart'; // Your dashboard screen
import '/widgtes/form_container_widget.dart'; // Import your custom form widget
import '/add/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmailRegistered = false;
  bool _isSigningUp = false;
  String? _selectedGender;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add the Sign Up heading above the container
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // First line
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'DreamCottage',
                        fontSize: 23,
                        color: Colors.black, // Set text color
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "\n\tERMO",
                          style: TextStyle(
                            fontFamily: 'Frista',
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10), // Space between lines
                  const Text(
                    "Your Skincare Journey Begins Here!",
                    style: TextStyle(
                      fontFamily: 'DreamCottage',
                      fontSize: 19,
                      color: Colors.black, // Set text color
                    ),
                    textAlign: TextAlign.center, // Center align the text
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: 340,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 238, 239),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FormContainerWidget(
                    formKey: _formKey,
                    submitButtonText: "Sign Up",
                    onSubmit: _handleSignUp,
                    fields: [
                      FormFieldData(
                        labelText: "Full Name",
                        hintText: "Enter Full Name",
                        controller: _nameController,
                      ),
                      FormFieldData(
                        labelText: "CNIC",
                        hintText: "XXXX  XXXXXXX  X",
                        controller: _cnicController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your CNIC';
                          }
                          if (value.length != 13) {
                            return 'CNIC must be 13 digits';
                          }
                          return null;
                        },
                      ),
                      FormFieldData(
                        labelText: "Age",
                        hintText: "Enter Age",
                        controller: _ageController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'Please enter a valid age';
                          }
                          return null;
                        },
                      ),
                      FormFieldData(
                        labelText: "Email",
                        hintText: "Enter Email",
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (_isEmailRegistered) return 'Already registered';
                          return null;
                        },
                        onChanged: (value) =>
                            _checkRegistration('email', value),
                      ),
                      FormFieldData(
                        labelText: "Password",
                        hintText: "Enter Password",
                        controller: _passwordController,
                        inputType: TextInputType.visiblePassword,
                        isPasswordField: true, // Enable password masking
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      FormFieldData(
                        labelText: "Gender",
                        hintText: "Select Gender",
                        controller:
                            TextEditingController(text: _selectedGender ?? ''),
                        inputType: TextInputType.none,
                        onTap: _buildGenderDropdown,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already registered? ",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 36, 36, 36),
                      fontFamily: 'DreamCottage',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const SignInScreen()),
                      );
                    },
                    child: const Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0), // Hex color
                        fontFamily: 'DreamCottage',
                      ),
                    ),
                  ),
                ],
              ),
              if (_isSigningUp) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkRegistration(String field, String value) async {
    if (value.isEmpty) return;

    final snapshot = await _firestore
        .collection('users')
        .where(field, isEqualTo: value)
        .get();

    setState(() {
      if (field == 'email') {
        _isEmailRegistered = snapshot.docs.isNotEmpty;
      }
    });
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState?.validate() == true) {
      setState(() {
        _isSigningUp = true;
      });

      try {
        // Sign up with email and password
        User? user = await AuthService().signUp(
            _emailController.text.trim(), _passwordController.text.trim());

        // Check if user is not null before proceeding
        if (user != null) {
          await _createUserInFirestore(user);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        } else {
          // Handle the case where user is null
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign up failed, please try again.')),
          );
        }
      } catch (e) {
        print('Error occurred during sign-up: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isSigningUp = false;
        });
      }
    }
  }

  Future<void> _createUserInFirestore(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'fullName': _nameController.text,
      'cnic': _cnicController.text,
      'age': _ageController.text,
      'email': _emailController.text,
      'gender': _selectedGender ?? '',
    });
  }

  Future<void> _buildGenderDropdown() async {
    final selectedGender = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Gender'),
          children: _genders.map((gender) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, gender);
              },
              child: Text(gender),
            );
          }).toList(),
        );
      },
    );

    setState(() {
      _selectedGender = selectedGender;
    });
  }
}
