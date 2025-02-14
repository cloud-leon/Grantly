import 'package:flutter/material.dart';

class GrantlyLogo extends StatelessWidget {
  final double? size;
  final bool useGradient;

  const GrantlyLogo({
    super.key,
    this.size,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: size ?? MediaQuery.of(context).size.width * 0.2,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    );

    if (!useGradient) {
      return Text(
        'Grantly',
        style: textStyle.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      );
    }

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF7B4DFF), // Deep purple
          Color(0xFF4D9FFF), // Light blue
        ],
      ).createShader(bounds),
      child: Text(
        'Grantly',
        style: textStyle.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
} 