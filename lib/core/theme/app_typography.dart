import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App typography using Lexend font family
/// Modern, minimal font sizes with Lexend from Google Fonts
class AppTypography {
  // Get Lexend font family
  static TextStyle _baseStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.lexend(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // Headings - Minimal sizes
  static TextStyle h1({Color? color, double? fontSize}) => _baseStyle(
    fontSize: fontSize ?? 32,
    fontWeight: FontWeight.bold,
    color: color,
    letterSpacing: 0.5,
  );

  static TextStyle h2({Color? color, double? fontSize}) => _baseStyle(
    fontSize: fontSize ?? 24,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.3,
  );

  static TextStyle h3({Color? color, double? fontSize}) => _baseStyle(
    fontSize: fontSize ?? 18,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.2,
  );

  // Body text - Standard sizes
  static TextStyle body({Color? color, double? fontSize}) => _baseStyle(
    fontSize: fontSize ?? 16,
    fontWeight: FontWeight.normal,
    color: color,
    letterSpacing: 0.1,
  );

  static TextStyle bodySmall({Color? color, double? fontSize}) => _baseStyle(
    fontSize: fontSize ?? 14,
    fontWeight: FontWeight.normal,
    color: color,
    letterSpacing: 0.1,
  );

  static TextStyle caption({Color? color, double? fontSize}) => _baseStyle(
    fontSize: fontSize ?? 12,
    fontWeight: FontWeight.normal,
    color: color,
    letterSpacing: 0.1,
  );

  // Button text
  static TextStyle button({Color? color}) => _baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.5,
  );
}
