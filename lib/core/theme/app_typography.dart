import 'package:flutter/material.dart';

/// App typography based on RealReel AI brand guidelines
/// Modern, minimal font sizes
class AppTypography {
  // Headings - Minimal sizes
  static TextStyle h1({Color? color, double? fontSize}) => TextStyle(
    fontSize: fontSize ?? 32,
    fontWeight: FontWeight.bold,
    color: color,
    letterSpacing: 0.5,
  );

  static TextStyle h2({Color? color, double? fontSize}) => TextStyle(
    fontSize: fontSize ?? 24,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.3,
  );

  static TextStyle h3({Color? color, double? fontSize}) => TextStyle(
    fontSize: fontSize ?? 18,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.2,
  );

  // Body text - Standard sizes
  static TextStyle body({Color? color, double? fontSize}) => TextStyle(
    fontSize: fontSize ?? 16,
    fontWeight: FontWeight.normal,
    color: color,
    letterSpacing: 0.1,
  );

  static TextStyle bodySmall({Color? color, double? fontSize}) => TextStyle(
    fontSize: fontSize ?? 14,
    fontWeight: FontWeight.normal,
    color: color,
    letterSpacing: 0.1,
  );

  static TextStyle caption({Color? color, double? fontSize}) => TextStyle(
    fontSize: fontSize ?? 12,
    fontWeight: FontWeight.normal,
    color: color,
    letterSpacing: 0.1,
  );

  // Button text
  static TextStyle button({Color? color}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.5,
  );
}
