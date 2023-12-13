import 'package:flutter/material.dart';

class textfield1 extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String label;
  final String keyboardtype;

  const textfield1({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.label,
    required this.keyboardtype,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return TextField(
      readOnly: true,
      keyboardType: getKeyboardType(),
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black12,
        hintText: hintText,
        labelText: label,
        contentPadding: EdgeInsets.all(screenWidth*0.015),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onChanged: (value) {
// do something
      },
    );
  }
}
