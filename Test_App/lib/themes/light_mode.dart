import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

ThemeData neoModernTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Roboto',

  scaffoldBackgroundColor: AppColors.bg,

  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accentGold,
    background: AppColors.bg,
    surface: AppColors.card,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textDark,
  ),

  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      statusBarIconBrightness: Brightness.light,
    ),
  ),

  cardTheme:  const CardThemeData(
    color: AppColors.card,
    elevation: 4,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(22)),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: const TextStyle(
      color: AppColors.textSoft,
      fontSize: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: Colors.transparent),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: Colors.transparent),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.6,
      ),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      elevation: 3,
    ),
  ),

  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: AppColors.textDark),
  ),
);

/// Global light theme
ThemeData lightMode = neoModernTheme;
