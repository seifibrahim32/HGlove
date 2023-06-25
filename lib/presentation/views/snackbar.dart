import 'package:flutter/material.dart';

showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: color,
    content: Text(message),
    duration: const Duration(seconds: 2),
  ));
}
