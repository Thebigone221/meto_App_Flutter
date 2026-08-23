import 'package:flutter/material.dart';

class AppGradients {
  static const darkColors = [
    Color(0xFF1A1A2E),
    Color(0xFF10102A),
    Color(0xFF080818),
  ];

  static const lightColors = [
    Color(0xFF87CEEB),
    Color(0xFFB8E4F0),
    Color(0xFFF2F2F7),
  ];

  static const stops = [0.0, 0.5, 1.0];

  static LinearGradient build(bool isDark) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark ? darkColors : lightColors,
      stops: stops,
    );
  }
}
