import 'package:flutter/material.dart';

class AppColors {
  /// Primary Royal Blue
  static const Color primary = Color(0xFF162E8B);
  static const Color primaryDark = Color(0xFF0F205E);

  /// Gold accent for highlights, chips, active states
  static const Color accentGold = Color(0xFFF2A900);

  /// Clean academic off-white background
  static const Color bg = Color(0xFFF7F7FC);

  /// Default card color
  static const Color card = Colors.white;

  /// Glass overlay color (used on video screens etc.)
  static const Color glass = Color(0x55FFFFFF);

  /// Text colors
  static const Color textDark = Color(0xFF141414);
  static const Color textSoft = Color(0xFF7D7D7D);

  /// Main gradient – Royal Blue → Gold
  static const LinearGradient mainGradient = LinearGradient(
    colors: [primary, accentGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
