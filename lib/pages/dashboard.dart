import 'package:flutter/material.dart';
import '/add/history_status.dart'; // Importing the HistoryStatus widget
import 'checkup.dart';
import 'alerts.dart';
import 'home.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isHovered = false;
  bool showSignOut = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Greeting with "ERMO says hi!" positioned at the center
                const Text(
                  "ERMO says hi!", // Display greeting message
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Frista',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(
                    height:
                        15), // Gap between the greeting and the HistoryStatus widget

                // Container for HistoryStatus widget
                HistoryStatus(), // Displaying the HistoryStatus widget

                const SizedBox(
                    height: 28), // Gap between the HistoryStatus and tabs

                // Horizontal Tabs
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: screenWidth * 0.9,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC2E8FF),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: _buildTab(
                        context,
                        "Checkup",
                        const ScanMeButton(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: screenWidth * 0.9,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCFFBDE),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: _buildTab(
                        context,
                        "Alert",
                        const AlertPage(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28), // Gap before Sign Out button

                // Sign Out Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'DreamCottage',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'DreamCottage',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 70, 69, 69),
          ),
        ),
      ),
    );
  }
}
