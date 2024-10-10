import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '/add/weather.dart';
//---------------------notification banner
import '/add/notification_time.dart';
import 'package:timezone/timezone.dart' as tb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  String _errorMessage = '';
  Map<String, dynamic>? _weatherData;
  String _alertMessage = '';
  String _recommendationMessage = '';

  // New fields for additional weather information
  String _sunriseTime = '';
  String _sunsetTime = '';
  String _currentTemperature = '';

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  // Function to get weather and display alerts based on the condition
  Future<void> _getWeather() async {
    try {
      Position position = await _determinePosition();
      WeatherService weatherService = WeatherService();
      Map<String, dynamic>? data = await weatherService.fetchWeather(position);

      // Print the weather data to console for debugging
      print(data.toString());

      // Check if data is not null and not empty
      if (data != null && data.isNotEmpty) {
        setState(() {
          _weatherData = data;
          String city = data.keys.first; // Get the first city as example

          // Check if expected keys exist to avoid null errors
          String weatherCondition = data[city]['weather'] ?? 'Unknown';
          double temperature = (data[city]['temperature'] ?? 0.0).toDouble();

          // Get additional weather details
          // Assuming sunrise and sunset are retrieved from your WeatherService or API.
          _sunriseTime = _formatTime(data[city]['sunrise'] ?? 0);
          _sunsetTime = _formatTime(data[city]['sunset'] ?? 0);
          _currentTemperature = temperature
              .toStringAsFixed(1); // Format temperature to one decimal

          // Set alert and recommendation based on weather condition
          _setAlertAndRecommendation(weatherCondition, temperature);
        });

        // Schedule notifications based on the weather condition
        await _scheduleNotification('Ermo Alerts!', _recommendationMessage);
      } else {
        setState(() {
          _errorMessage = 'No weather data available.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching weather: $e';
      });
    }
  }

  // Function to schedule notifications
  Future<void> _scheduleNotification(String title, String body) async {
    // Schedule the notification for a few minutes from now
    tb.TZDateTime scheduledDate =
        tb.TZDateTime.now(tb.local).add(const Duration(minutes: 5));

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'activity_reminder_channel', // Channel ID
      'Activity Reminders', // Channel name
      channelDescription:
          'Notifications for scheduled activities and reminders', // Channel description
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      title, // Title
      body, // Body
      scheduledDate, // Scheduled date/time
      platformChannelSpecifics, // Notification details
      androidScheduleMode:
          AndroidScheduleMode.exact, // Replace deprecated parameter
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime, // Interpretation
      matchDateTimeComponents:
          DateTimeComponents.dateAndTime, // Match date and time components
    );
  }

  // Function to format time from String to desired format
  String _formatTime(String time) {
    DateTime dateTime = DateTime.parse(time);
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'p.m' : 'a.m'}";
  }

  // Function to determine user's location
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Function to set alert and recommendation messages based on weather
  void _setAlertAndRecommendation(String weatherCondition, double temperature) {
    if (weatherCondition.contains('hot')) {
      _alertMessage = 'It’s scorching outside! Reapply sunscreen.';
      _recommendationMessage =
          'Stay cool! Drink water and wear light clothing.';
    } else if (weatherCondition.contains('clear') ||
        weatherCondition.contains('sunny')) {
      _alertMessage = 'The sun is shining bright!';
      _recommendationMessage = 'Wear sunglasses and keep an umbrella handy.';
    } else if (weatherCondition.contains('humid')) {
      _alertMessage = 'It’s humid today! Hydrate your skin.';
      _recommendationMessage = 'Eat watermelon and cucumbers to stay cool.';
    } else if (weatherCondition.contains('windy')) {
      _alertMessage = 'Strong winds! Use a moisturizer.';
      _recommendationMessage = 'Secure your hair to avoid wind damage.';
    } else if (weatherCondition.contains('cold')) {
      _alertMessage = 'Cold weather ahead! Use a thick moisturizer.';
      _recommendationMessage = 'Cover exposed skin to prevent dryness.';
    } else if (weatherCondition.contains('rain')) {
      _alertMessage = 'It’s raining! Use waterproof sunscreen.';
      _recommendationMessage = 'Keep your skin clean and moisturized.';
    } else if (weatherCondition.contains('pollen')) {
      _alertMessage = 'High pollen levels! Wash your face.';
      _recommendationMessage = 'Use a gentle cleanser to avoid breakouts.';
    } else if (weatherCondition.contains('pollution')) {
      _alertMessage = 'Poor air quality! Avoid sun exposure.';
      _recommendationMessage = 'Use antioxidant-rich skincare products.';
    } else {
      _alertMessage = 'Weather data unavailable!';
      _recommendationMessage = 'Please check your network connection.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFFEB),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _navigateToDashboard(); // Navigate back
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  transform: Matrix4.translationValues(
                      0, (5 * (0.5 - (0.5 + 0.5))), 0),
                  child: Image.asset(
                    'assets/images/greenErmo.webp', // Update with your image path
                    width: 300,
                    height: 200,
                  ),
                ),
              ),
              if (_weatherData != null) ...[
                Text(
                  _alertMessage,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Current Temperature: $_currentTemperature °C',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  'Sunrise: $_sunriseTime',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  'Sunset: $_sunsetTime',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
              ] else if (_errorMessage.isNotEmpty) ...[
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Navigate to Dashboard
  void _navigateToDashboard() {
    Navigator.pop(context); // Pops the current page off the stack
  }
}
