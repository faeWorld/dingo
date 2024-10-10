import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WeatherService {
  final String apiKey =
      '9d8e7b236c0458fea3550a59b4c4bc28'; // Replace with your actual API key

  Future<Map<String, dynamic>?> fetchWeather(Position position) async {
    // List of cities to check based on user location
    List<String> cities = [
      'Karachi',
      'Lahore',
      'Islamabad',
      'Abbottabad',
      'Jhelum',
      'Peshawar',
      'Quetta'
    ];

    // Create a map to hold city weather data
    Map<String, dynamic> weatherData = {};

    for (String city in cities) {
      // Construct the URL with the city name and API key
      String url =
          'https://api.openweathermap.org/data/2.5/weather?q=$city,PK&appid=$apiKey&units=metric';

      // Make the API call
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        weatherData[city] = {
          'temperature': data['main']['temp'],
          'weather': data['weather'][0]['description'],
        };
      } else {
        print('Failed to load weather data for $city: ${response.body}');
      }
    }
    return weatherData;
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String _errorMessage = '';
  // Weather? _weatherData;
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    try {
      Position position = await _determinePosition();
      WeatherFactory wf = WeatherFactory("9d8e7b236c0458fea3550a59b4c4bc28");

      // List of cities to check based on user location
      List<String> cities = [
        'Karachi',
        'Lahore',
        'Islamabad',
        'Abbottabad',
        'Jhelum',
        'Peshawar',
        'Quetta',
      ];

      // Create a map to hold city weather data
      Map<String, Weather> weatherData = {};

      // Fetch weather data for each city
      for (String city in cities) {
        Weather weather = await wf.currentWeatherByCityName(city);
        weatherData[city] = weather;
      }

      setState(() {
        _weatherData = weatherData;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching weather: $e';
      });
    }
  }

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

  String _formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime); // Formats time like 04:30 AM
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy')
        .format(dateTime); // Formats date as 13/07/2024
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Weather in Pakistan')),
      body: Center(
        child: _weatherData != null
            ? ListView.builder(
                itemCount: _weatherData!.length,
                itemBuilder: (context, index) {
                  String city = _weatherData!.keys.elementAt(index);
                  Weather weather = _weatherData![city];

                  // Use null-aware access to avoid errors if any data is missing
                  DateTime? sunrise = weather.sunrise;
                  DateTime? sunset = weather.sunset;
                  DateTime? date = weather.date;
                  double? temperature = weather.temperature?.celsius;

                  return ListTile(
                    title: Text(city),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Date: ${date != null ? _formatDate(date) : 'N/A'}'),
                        Text(
                            'Sunrise: ${sunrise != null ? _formatTime(sunrise) : 'N/A'}'),
                        Text(
                            'Sunset: ${sunset != null ? _formatTime(sunset) : 'N/A'}'),
                        Text(
                            'Temperature: ${temperature != null ? temperature.toString() : 'N/A'} °C'),
                      ],
                    ),
                  );
                },
              )
            : Text(_errorMessage.isEmpty ? 'Loading...' : _errorMessage),
      ),
    );
  }
}
