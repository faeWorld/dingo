import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider for state management
import 'signup.dart'; // Adjust the path as needed
import 'package:tflite/tflite.dart';
//import 'package:tflite_flutter/tflite_flutter.dart';

class ErmoApp extends StatelessWidget {
  const ErmoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15), // Adjust the duration
      vsync: this,
    )..repeat(); // Repeat indefinitely

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear, // Linear curve for constant speed
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCharacterClick() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignUpScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, 1.0); // Start from the bottom
          var end = Offset.zero; // Move to the top
          var curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Ombre background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xffe94b5fd), Color(0xFFFF81AF)],
              ),
            ),
          ),
          // Custom Painted ERMO Banner
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: BannerPainter(
                  animation: _animation,
                  screenWidth: screenWidth,
                ),
                child: const SizedBox
                    .expand(), // Expand to fill the available space
              );
            },
          ),
          // Jiggling Character
          Positioned(
            left: 150,
            top: 661,
            child: GestureDetector(
              onTap: _onCharacterClick,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset:
                        Offset(0, _animation.value * 3.5), // Jiggle up and down
                    child: Image.asset(
                      'assets/images/ermo.webp', // Replace with your character's image
                      width: 78, // Width
                      height: 89, // Height
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BannerPainter extends CustomPainter {
  final Animation<double> animation;
  final double screenWidth;

  BannerPainter({required this.animation, required this.screenWidth})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'ERMO.ERMO.ERMO.ERMO.',
        style: TextStyle(
          fontSize: 220,
          color: Colors.white,
          fontFamily: 'Frista',
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: screenWidth * 6);

    // Calculate the total width of the text
    final textWidth = textPainter.width;

    // Calculate the offset based on the animation value
    final offsetX = (animation.value * screenWidth * 0.25) %
        textWidth; // Adjust multiplier for readable speed

    // Paint the text twice to achieve the looping effect
    textPainter.paint(canvas, Offset(-offsetX, 247));
    textPainter.paint(canvas, Offset(-offsetX + textWidth, 247));
  }

  @override
  bool shouldRepaint(BannerPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

//------------------------------the model is only loaded once and can be accessed from anywhere in your app.

