import 'package:flutter/material.dart';

class NavigationUtils {
  static void onBack(BuildContext context, Widget destination) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: Duration.zero,
      ),
    );
  }

  static void onNext(BuildContext context, Widget destination) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: Duration.zero,
      ),
    );
  }
} 