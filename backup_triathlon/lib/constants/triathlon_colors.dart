import 'package:flutter/material.dart';

class TriathlonColors {
  // Couleurs principales
  static const Color primary = Color(0xFF1565C0); // Bleu triathlon
  static const Color secondary = Color(0xFF42A5F5);
  static const Color background = Color(0xFFF5F5F5);

  // Couleurs par sport
  static const Color swimming = Color(0xFF00ACC1); // Cyan pour natation
  static const Color cycling = Color(0xFF4CAF50); // Vert pour cyclisme
  static const Color running =
      Color(0xFFE53935); // Rouge pour course (identique à votre ancienne app)

  // Couleurs UI
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);

  // Gradients
  static const List<Color> swimmingGradient = [
    Color(0xFF00ACC1),
    Color(0xFF26C6DA),
  ];

  static const List<Color> cyclingGradient = [
    Color(0xFF4CAF50),
    Color(0xFF66BB6A),
  ];

  static const List<Color> runningGradient = [
    Color(0xFFE53935),
    Color(0xFFEF5350),
  ];
}
