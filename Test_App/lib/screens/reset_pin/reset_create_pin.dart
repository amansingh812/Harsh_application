import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:school_scout/apis/reser_pin_service.dart';
import 'package:school_scout/global/global_data.dart';
import 'package:school_scout/screens/login/enter_pin_screen.dart';
import 'package:school_scout/widgets/app_elevated_button.dart';
import '../../apis/registeration_service.dart';
import '../../widgets/my_bottomNavigator.dart';

import 'dart:ui'; // for ImageFilter.blur
import 'package:video_player/video_player.dart';

import '../login/login_page.dart';


class ResetCreatePin extends StatefulWidget {
  const ResetCreatePin({super.key});

  @override
  State<ResetCreatePin> createState() => _ResetCreatePinState();
}

class _ResetCreatePinState extends State<ResetCreatePin> {
  final _formKey = GlobalKey<FormState>();


  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isSubmitButtonEnabled = false;
  bool isLoading = false;

  final RegistrationService _registrationService = RegistrationService();

  late VideoPlayerController _videoController;

  // === Validation Helpers ===
  bool _isValidPhone(String v) => RegExp(r'^[6789]\d{9}$').hasMatch(v);
  bool _isValidName(String v) => RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim());
  bool _isValidPin(String v) => RegExp(r'^\d{4}$').hasMatch(v);

  void _updateSubmitState() {
    final ok = _isValidPin(passwordController.text) &&
        passwordController.text == confirmPasswordController.text;
    if (isSubmitButtonEnabled != ok) {
      setState(() => isSubmitButtonEnabled = ok);
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final String mobNumber = GlobalData().mobNumber.toString();
    final String newPin = passwordController.text.trim();

    setState(() => isLoading = true);

    try {
      final response = await ResetPinService().resetPin(
        mobNumber,
        newPin,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (response['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnterPinScreen(mobileNumber: mobNumber),
          ),
        );
      } else {
        _showError(response['message']); // 👈 NOW shows "No records found"
      }

    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showError('An error occurred: $e');
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    for (final c in [

      passwordController,
      confirmPasswordController,
    ]) {
      c.addListener(_updateSubmitState);
    }

    _videoController = VideoPlayerController.asset(
      'assets/videos/Video_Resized_For_Mobile_App.mp4',
    )
      ..initialize().then((_) {
        if (!mounted) return;
        _videoController
          ..setLooping(true)
          ..setVolume(0.0)
          ..play();
        setState(() {}); // show video
      });
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    _videoController.dispose();
    super.dispose();
  }
  PinTheme _basePinTheme(BuildContext context) {
    return PinTheme(
      height: 56,
      width: 56,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white38,
          width: 1,
        ),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: Colors.black,
      ),
    );
  }

  PinTheme _focusedPinTheme(BuildContext context) {
    return _basePinTheme(context).copyWith(
      decoration: _basePinTheme(context).decoration!.copyWith(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }

  PinTheme _errorPinTheme() {
    return PinTheme(
      height: 56,
      width: 56,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.redAccent,
          width: 1.8,
        ),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: Colors.redAccent,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ===== VIDEO BACKGROUND =====
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
                : Container(color: Colors.black),
          ),

          // ===== DARK OVERLAY =====
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          // ===== FOREGROUND CONTENT =====
          SafeArea(
            child: Stack(
              children: [


                // Header (logo + title)
                Positioned(
                  top: 24,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "SchoolScout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Find the perfect school for your child",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== BOTTOM GLASS CARD =====
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pill
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius:
                                          BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.auto_awesome,
                                              size: 16,
                                              color: colorScheme.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Reset PIN",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),



                                    _label("Create 4-digit PIN"),
                                    const SizedBox(height: 16),

                                    Center(
                                      child: Pinput(
                                        controller: passwordController,
                                        length: 4,
                                        obscureText: true,
                                        keyboardType: TextInputType.number,
                                        autofocus: false,
                                        defaultPinTheme: _basePinTheme(context),
                                        focusedPinTheme: _focusedPinTheme(context),
                                        submittedPinTheme: _focusedPinTheme(context),
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        onChanged: (_) => _updateSubmitState(),
                                        validator: (value) {
                                          if (value == null || value.length != 4) {
                                            return "Enter 4 digit PIN";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),



                                    const SizedBox(height: 14),

                                    // CONFIRM PIN
                                    _label("Confirm PIN"),
                                    const SizedBox(height: 16),

                                    Center(
                                      child: Pinput(
                                        controller: confirmPasswordController,
                                        length: 4,
                                        obscureText: true,
                                        keyboardType: TextInputType.number,
                                        defaultPinTheme: _basePinTheme(context),
                                        focusedPinTheme: _focusedPinTheme(context),
                                        submittedPinTheme: _focusedPinTheme(context),
                                        errorPinTheme: _errorPinTheme(), // 🔥 IMPORTANT
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        onChanged: (_) => _updateSubmitState(),
                                        onCompleted: (_) => _registerUser(),
                                        validator: (value) {
                                          if (value == null || value.length != 4) {
                                            return "Re-enter PIN";
                                          }
                                          if (value != passwordController.text) {
                                            HapticFeedback.lightImpact();
                                            return "PINs do not match";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),


                                    const SizedBox(height: 20),

                                    // BUTTON
                                    SizedBox(
                                      width: double.infinity,
                                      child: AppElevatedButton(
                                        onPressed:
                                        isSubmitButtonEnabled &&
                                            !isLoading
                                            ? _registerUser
                                            : null,
                                        text: isLoading
                                            ? "Please wait…"
                                            : "Resetting PIN",
                                      ),
                                    ),

                                    const SizedBox(height: 16),
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const LoginPage(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Sign in →",
                                          style: TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== LOADING OVERLAY =====
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }
}


