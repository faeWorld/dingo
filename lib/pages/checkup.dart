import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';
import 'package:dingo/add/photo_service.dart';
//import 'package:image/image.dart' as img;
//import 'package:tflite/tflite.dart';

import 'dashboard.dart'; // Your dashboard screen

class ScanMeButton extends StatefulWidget {
  const ScanMeButton({super.key});

  @override
  _ScanMeButtonState createState() => _ScanMeButtonState();
}

class _ScanMeButtonState extends State<ScanMeButton> {
  final ImagePicker _picker = ImagePicker();
  bool isProcessing = false;
  bool isCapturing = false;

  String diseaseName = "";
  String diseaseType = "";
  double matchPercentage = 0.0;

  @override
  void initState() {
    super.initState();
//    ChangeNotifierProvider(
    //    create: (_) => ModelProvider()..loadModel(), // Load model on startup
    //  child: const ErmoApp(),
    //);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ModelProvider>(context, listen: false).loadModel();
    });
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      isProcessing = true;
    });

    try {
      final modelProvider = Provider.of<ModelProvider>(context, listen: false);
      await modelProvider.processImage(imageFile);
      setState(() {
        diseaseName = modelProvider.diseaseName;
        diseaseType = modelProvider.diseaseType;
        matchPercentage = modelProvider.matchPercentage;
      });
    } catch (e) {
      _showSnackbar('Error processing image: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _askForPermission(
      Permission permission, Function onGrant) async {
    if (await permission.request().isGranted) {
      onGrant();
    } else {
      _showSnackbar(
          '${permission.toString().split('.').last} permission denied.');
    }
  }

  void _openCamera() async {
    if (isCapturing) return;
    setState(() {
      isCapturing = true;
    });

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      await _processImage(File(photo.path));
    }
    setState(() {
      isCapturing = false;
    });
  }

  void _openGallery() async {
    if (isCapturing) return;
    setState(() {
      isCapturing = true;
    });

    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      await _processImage(File(photo.path));
    }
    setState(() {
      isCapturing = false;
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 249, 254),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Dashboard())),
                child: Image.asset(
                  'assets/images/blueErmo.webp',
                  width: 65,
                  height: 74,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 356,
                decoration: BoxDecoration(
                  color: const Color(0xFFC2E8FF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 6),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Check Up",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'DreamCottage',
                            color: Colors.black),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () =>
                            _askForPermission(Permission.camera, _openCamera),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF022E47),
                          fixedSize: const Size(330, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Take Picture",
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'DreamCottage',
                                color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () =>
                            _askForPermission(Permission.photos, _openGallery),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF022E47),
                          fixedSize: const Size(330, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Upload Picture",
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'DreamCottage',
                                color: Colors.white)),
                      ),
                      if (isCapturing) const CircularProgressIndicator(),
                      if (!isCapturing && diseaseName.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: 350,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Detected Disease:  $diseaseName",
                                  style: const TextStyle(
                                      fontFamily: 'DreamCottage',
                                      fontSize: 18)),
                              Text("Disease Type:  $diseaseType",
                                  style: const TextStyle(
                                      fontFamily: 'DreamCottage',
                                      fontSize: 18)),
                              Text("Match:  $matchPercentage%",
                                  style: const TextStyle(
                                      fontFamily: 'DreamCottage',
                                      fontSize: 18)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//final modelProvider = Provider.of<ModelProvider>(context);

/**The provided code defines a Flutter widget for scanning images to diagnose skin diseases using 
 * a machine learning model. It allows users to capture photos or upload images, processes 
 * the images for analysis, and displays the detected disease information along with a match percentage.
 *  It includes functionality for handling permissions, image processing, 
 * and displaying results in a user-friendly interface. */

class ModelManager {
  static final ModelManager _instance = ModelManager._internal();
  late String _modelPath; // Store the model path
  bool isModelLoaded = false; // Track whether the model is loaded

  factory ModelManager() {
    return _instance;
  }

  ModelManager._internal() {
    _modelPath = 'assets/model.tflite'; // Path to your model in assets
  }

  Future<void> loadModel() async {
    // Load your model here, if it's not already loaded
    if (!isModelLoaded) {
      // Load the model from assets
      String? result = await Tflite.loadModel(
        model: _modelPath,
      );
      if (result == 'success') {
        isModelLoaded = true;
        print('Model loaded successfully!');
      } else {
        print('Failed to load model: $result');
      }
    }
  }

  // Method to perform inference
  Future<List?> runModelOnImage(String imagePath) async {
    if (!isModelLoaded) {
      print('Model is not loaded. Please load the model first.');
      return null;
    }

    // Run inference on the image
    var result = await Tflite.runModelOnImage(
      path: imagePath, // Path to the image to analyze
      numResults: 1, // Number of results to return
      threshold: 0.5, // Confidence threshold
    );
    return result;
  }
}

//----------------------create a model provider that loads the model once and provides it throughout your app.

class ModelProvider with ChangeNotifier {
  String _diseaseName = '';
  String _diseaseType = '';
  double _matchPercentage = 0.0;
  String _age = '';
  String _sex = '';
  String _localization = '';

  String get diseaseName => _diseaseName;
  String get diseaseType => _diseaseType;
  double get matchPercentage => _matchPercentage;
  String get age => _age;
  String get sex => _sex;
  String get localization => _localization;

  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    // Load your model here
    await Tflite.loadModel(model: "assets/model.tflite");
    _isModelLoaded = true;
    notifyListeners();
  }

  Future<void> processImage(File imageFile) async {
    final results = await runModelOnImage(imageFile.path); // Pass the path here
    if (results != null && results.isNotEmpty) {
      // Assuming the first result is the one we want
      _diseaseName = results[0]['dx'] ?? 'Unknown';
      _diseaseType = results[0]['dx_type'] ?? 'Unknown';
      _matchPercentage = results[0]['match_percentage']?.toDouble() ??
          0.0; // Adjust as necessary
      _age = results[0]['age'] ?? 'Unknown';
      _sex = results[0]['sex'] ?? 'Unknown';
      _localization = results[0]['localization'] ?? 'Unknown';
    } else {
      // Handle case where results are null or empty
      _diseaseName = 'Unknown';
      _diseaseType = 'Unknown';
      _matchPercentage = 0.0;
      _age = 'Unknown';
      _sex = 'Unknown';
      _localization = 'Unknown';
    }
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>?> runModelOnImage(String imagePath) async {
    if (!_isModelLoaded) {
      print('Model is not loaded.');
      return null;
    }

    // Ensure you use the correct path type
    var result = await Tflite.runModelOnImage(
      path: imagePath, // Pass the image path as a string
      numResults: 1,
      threshold: 0.5,
    );

    if (result != null && result.isNotEmpty) {
      return result.map((item) {
        return {
          'lesion_id': item['lesion_id'],
          'image_id': item['image_id'],
          'dx': item['dx'],
          'dx_type': item['dx_type'],
          'age': item['age'],
          'sex': item['sex'],
          'localization': item['localization'],
          'match_percentage':
              item['match_percentage'], // Assuming you have this key
        };
      }).toList();
    }

    return null;
  }
}
