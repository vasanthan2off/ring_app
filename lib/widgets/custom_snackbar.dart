import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(
      BuildContext context,
      String message, {
        Color backgroundColor = Colors.black87,
        Color textColor = Colors.white,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
