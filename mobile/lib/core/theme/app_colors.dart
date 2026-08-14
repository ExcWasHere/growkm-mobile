import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //Palette Guys
  static const Color primary = Color(0xFFF59E0B);
  static const Color primaryDark = Color(0xFFD97706);
  static const Color primaryLight = Color(0xFFFEF3C7);
  static const Color secondary = Color(0xFFF97316);
  static const Color secondaryDark = Color(0xFFEA580C);
  static const Color accentLight = Color(0xFFFDE68A);

  static const Color white = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1F2937);
  static const Color inkMuted = Color(0xFF374151);
  static const Color mist = Color(0xFFF9FAFB);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandTextGradient = LinearGradient(
    colors: [primaryDark, secondaryDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}