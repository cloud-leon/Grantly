import 'package:flutter/material.dart';

class TestWrapper extends StatelessWidget {
  final Widget child;

  const TestWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)),
        child: Material(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                width: 400,
                height: 800,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 