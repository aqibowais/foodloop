import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';

class AppToast {
  static void success(BuildContext context, String message) {
    CherryToast.success(
      title: Text(message, style: const TextStyle(color: Colors.black)),
      animationType: AnimationType.fromBottom,
      toastDuration: const Duration(seconds: 3),
    ).show(context);
  }

  static void error(BuildContext context, String message) {
    CherryToast.error(
      title: Text(message, style: const TextStyle(color: Colors.black)),
      animationType: AnimationType.fromBottom,
      toastDuration: const Duration(seconds: 3),
    ).show(context);
  }

  static void info(BuildContext context, String message) {
    CherryToast.info(
      title: Text(message, style: const TextStyle(color: Colors.black)),
      animationType: AnimationType.fromBottom,
      toastDuration: const Duration(seconds: 3),
    ).show(context);
  }
}
