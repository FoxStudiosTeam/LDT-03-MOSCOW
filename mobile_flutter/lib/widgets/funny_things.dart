
import 'package:flutter/material.dart';

void showErrSnackbar(BuildContext ctx, String message) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );
}


void showSuccessSnackbar(BuildContext ctx, String message) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
    ),
  );
}


void showWarnSnackbar(BuildContext ctx, String message) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(message,
      style: const TextStyle(color: Colors.black),),
      backgroundColor: Colors.yellow,
      duration: const Duration(seconds: 3),
    ),
  );
}
