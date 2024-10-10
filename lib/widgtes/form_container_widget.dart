import 'package:flutter/material.dart';

class FormContainerWidget extends StatelessWidget {
  const FormContainerWidget({
    super.key,
    required this.formKey,
    required this.submitButtonText,
    required this.onSubmit,
    required this.fields,
  });

  final GlobalKey<FormState> formKey;
  final String submitButtonText;
  final VoidCallback onSubmit;
  final List<FormFieldData> fields;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dynamically build fields
          ...fields.map((field) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: _buildField(field),
            );
          }),

          const SizedBox(height: 20),
          // Sign Up Button
          Center(
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50), // Button size from Figma
                backgroundColor: const Color.fromARGB(
                    255, 88, 0, 45), // Button background color
                foregroundColor: Colors.white, // Button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'DreamCottage', // Updated font to Frista
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(
                submitButtonText,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
              height: 10), // Add 10 pixels of padding after the button
        ],
      ),
    );
  }
}

// Build individual fields
Widget _buildField(FormFieldData field) {
  return SizedBox(
    width: 300, // Width from Figma
    height: 55, // Height from Figma
    child: TextFormField(
      controller: field.controller,
      decoration: InputDecoration(
        labelText: field.labelText,
        hintText: field.hintText,
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        // Background color from Figma --const Color(0xFFEFFAFF)

        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 85, 84, 84),
          fontFamily: 'DreamCottage', // Updated to Frista
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),

        hintStyle: const TextStyle(
          color: Color.fromARGB(255, 97, 97, 97),
          fontFamily: 'DreamCottage', // Updated to Frista
          fontSize: 16,
        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0, // Padding for vertical spacing
          horizontal: 10.0, // Ensure at least 10px horizontal space for label
        ), // Adjust the padding for spacing

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Corner radius from Figma
          borderSide: BorderSide.none, // No border
        ),
      ),
      style: const TextStyle(
        color: Colors.black,
        fontFamily: 'DreamCottage', // Updated to Frista
      ),

      keyboardType: field.inputType,
      validator: field.validator,
      onChanged: field.onChanged,
      onTap: field.onTap,
      obscureText: field.isPasswordField, // Handle password obscuring
    ),
  );
}

// Form field data model
class FormFieldData {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function()? onTap;
  final bool isPasswordField;
  final bool obscureText;

  FormFieldData({
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.inputType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onTap,
    this.isPasswordField = false, // Password field flag
    this.obscureText = false,
  });
}
