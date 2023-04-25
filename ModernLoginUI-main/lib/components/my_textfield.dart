import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final Icon prefixicon;
  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.prefixicon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            prefixIcon: prefixicon,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
            ),
            fillColor: Color.fromARGB(255, 255, 255, 255),
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(
                fontWeight: FontWeight.bold, // set the font weight to bold
                fontStyle: FontStyle.normal, // set the font style to normal
                fontSize: 16, // set the font size
                fontFamily: 'Inter',
                color: Color.fromARGB(255, 0, 0, 0))),
      ),
    );
  }
}
