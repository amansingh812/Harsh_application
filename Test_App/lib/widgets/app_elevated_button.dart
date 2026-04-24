import 'package:flutter/material.dart';

import 'buttons/buttons_helper.dart';

export 'buttons/buttons_helper.dart';

class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor, // Removed default color to allow theme to take over
    this.foregroundColor, // Removed default color
    this.buttonSize = ButtonSize.xLarge,
  });

  /// Black Colored Elevated Button
  factory AppElevatedButton.primary({
    required void Function()? onPressed,
    required String text,
    ButtonSize buttonSize = ButtonSize.xLarge,
  }) =>
      AppElevatedButton(
        onPressed: onPressed,
        text: text,
        backgroundColor: const Color(0xFF000000),
        foregroundColor: const Color(0xFFFFFFFF),
        buttonSize: buttonSize,
      );

  /// Yellow Colored Elevated Button
  factory AppElevatedButton.secondary({
    required void Function()? onPressed,
    required String text,
    ButtonSize buttonSize = ButtonSize.xLarge,
  }) =>
      AppElevatedButton(
        onPressed: onPressed,
        text: text,
        backgroundColor: const Color(0xFFF9C623),
        foregroundColor: const Color(0xFF000000),
        buttonSize: buttonSize,
      );

  final void Function()? onPressed;
  final String text;
  final Color? backgroundColor; // Now nullable to respect the theme
  final Color? foregroundColor; // Now nullable
  final ButtonSize buttonSize;

  @override
  Widget build(BuildContext context) {
    // Using ElevatedButton.styleFrom for a cleaner approach
    final buttonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: backgroundColor, // Will use theme color if this is null
      foregroundColor: foregroundColor, // Will use theme color if this is null
      disabledBackgroundColor: const Color(0xFFE2E2E2),
      disabledForegroundColor: const Color(0xFFA4A4A4),
      minimumSize: Size.fromHeight(
        getButtonSize(buttonSize),
      ),
      // --- THIS IS THE KEY CHANGE FOR THE MODERN LOOK ---
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22), // Creates a pill/stadium shape
      ),
      textStyle: TextStyle(
        fontSize: buttonSize == ButtonSize.xxSmall ? 12 : 14,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
