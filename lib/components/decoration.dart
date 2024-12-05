import 'package:flutter/material.dart';

InputDecoration getLoginInputDecoration(String label) {
  return InputDecoration(
    hintText: label,
    fillColor: Colors.white,
    filled: true,
    contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(
        color: Colors.black,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 27, 10, 72),
        width: 3,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 3,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 3,
      ),
    ),
  );
}
