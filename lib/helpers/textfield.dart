import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class textfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String keyboardtype;

  const textfield({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.keyboardtype,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    TextInputType getKeyboardType() {
      switch (keyboardtype) {
        case 'phone':
          return TextInputType.phone;
        case 'number':
          return TextInputType.number;
        case 'text':
          return TextInputType.text;
        default:
          return TextInputType.text;
      }
    }

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white54,
        hintText: hintText,
        contentPadding: EdgeInsets.all(screenWidth * 0.015),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      keyboardType: getKeyboardType(), // Set the keyboard type dynamically
      onChanged: (value) {
        // do something
      },
    );
  }
}

class textfield1 extends StatelessWidget {
  final MaskedTextController controller;
  final String hintText;
  final String keyboardtype;

  const textfield1({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.keyboardtype,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    TextInputType getKeyboardType() {
      switch (keyboardtype) {
        case 'phone':
          return TextInputType.phone;
        case 'number':
          return TextInputType.number;
        case 'text':
          return TextInputType.text;
        default:
          return TextInputType.text;
      }
    }

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white54,
        hintText: hintText,
        contentPadding: EdgeInsets.all(screenWidth * 0.015),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      keyboardType: getKeyboardType(), // Set the keyboard type dynamically
      onChanged: (value) {
        // do something
      },
    );
  }
}

