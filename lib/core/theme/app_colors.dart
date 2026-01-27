import 'package:flutter/material.dart';

/// App color palette for FoodLoop
/// Dark, neon-green inspired palette similar to reference screens
class AppColors {
  // Brand / Accent
  static const Color accentGreen = Color(0xFFB6FF3A);
  static const Color accentGreenSoft = Color(0xFF8EDB2D);

  // Neutrals
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF050608);
  static const Color darkGrey = Color(0xFF0D0F12);
  static const Color cardDark = Color(0xFF15181D);
  static const Color grey = Color(0xFF7A7F85);
  static const Color lightGrey = Color(0xFF2A2E35);

  // Gradient for large backgrounds (splash/onboarding)
  static const Color gradientStart = Color(0xFF050608); // near-black
  static const Color gradientMiddle = Color(0xFF0F1116); // deep grey
  static const Color gradientEnd = Color(0xFF15181D); // cardDark-ish
}
