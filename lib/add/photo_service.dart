import 'package:flutter/material.dart';

class PhotoInstructions {
  static Widget getInstructions() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Photo Instructions:",
            style: TextStyle(
                fontSize: 15,
                fontFamily: 'DreamCottage',
                fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text("1. Ensure good lighting when taking the picture.",
            style: TextStyle(fontFamily: 'DreamCottage')),
        Text("2. Hold your phone about 12 inches away.",
            style: TextStyle(fontFamily: 'DreamCottage')),
        Text("3. Make sure the affected area is in focus.",
            style: TextStyle(fontFamily: 'DreamCottage')),
      ],
    );
  }
}
