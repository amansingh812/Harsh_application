import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:school_scout/screens/login/register_page.dart';
import 'package:school_scout/screens/reset_pin/reset_create_pin.dart';

import '../../widgets/my_bottomNavigator.dart';
// for ImageFilter.blur
import 'package:video_player/video_player.dart';  // for background video



class ResetEnterOtpScreen extends StatefulWidget {
  const ResetEnterOtpScreen({
    super.key,
    required this.mobileNumber,
    required this.verificationId,
    required this.resendToken,
  });

  final String mobileNumber;
  final String verificationId;
  final int? resendToken;


  @override
  State<ResetEnterOtpScreen> createState() => _ResetEnterOtpScreenState();
}

class _ResetEnterOtpScreenState extends State<ResetEnterOtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  bool isLoading = false;
  bool isSubmitEnabled = false;
  bool canResendOtp = false;

  int _secondsRemaining = 60;
  Timer? _timer;
  int resendAttempts = 0;
  static const int maxResendAttempts = 3;
  late String _verificationId; // mutable
  int? _resendToken;
  late VideoPlayerController _videoController;


  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      'assets/videos/Video_Resized_For_Mobile_App.mp4',
    )
      ..initialize().then((_) {
        if (!mounted) return;
        _videoController
          ..setLooping(true)
          ..setVolume(0.0)
          ..play();
        setState(() {});
      });

    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;

    _startResendTimer();

    Future.delayed(const Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_pinFocusNode);
    });
  }



  @override
  void dispose() {
    otpController.dispose();
    _pinFocusNode.dispose();
    _timer?.cancel();
    _videoController.dispose();

    super.dispose();
  }

  // ================= TIMER =================
  void _startResendTimer() {
    canResendOtp = false;
    _secondsRemaining = 60;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() => canResendOtp = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  // ================= OTP VALIDATION =================
  bool _validateOtp(String value) {
    final valid = value.length == 6 && RegExp(r'^[0-9]+$').hasMatch(value);
    setState(() => isSubmitEnabled = valid);
    return valid;
  }

  // ================= VERIFY OTP =================
  Future<void> _verifyOtp() async {
    if (isLoading) return; // 🔒 prevent double submit

    setState(() => isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otpController.text,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ResetCreatePin(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showError(
        e.code == 'invalid-verification-code'
            ? 'Invalid OTP'
            : 'Verification failed',
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  // ================= RESEND OTP =================
  Future<void> _resendOtp() async {
    if (!canResendOtp) return;

    if (resendAttempts >= maxResendAttempts) {
      _showError("You have reached the maximum resend limit");
      return;
    }

    resendAttempts++;
    _startResendTimer();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${widget.mobileNumber}',
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,

      verificationCompleted: (_) {},

      verificationFailed: (FirebaseAuthException e) {
        _showError(e.message ?? 'Failed to resend OTP');
      },

      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          otpController.clear();

          // ✅ update STATE values (allowed)
          _verificationId = verificationId;
          _resendToken = resendToken;
        });
      },

      codeAutoRetrievalTimeout: (_) {},
    );
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

  // ================= UI =================

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

          // ===== FOREGROUND =====
          SafeArea(
            child: Stack(
              children: [
                // HEADER
                Positioned(
                  top: 24,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.school, color: Colors.white, size: 32),
                      SizedBox(height: 12),
                      Text(
                        "Verify OTP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Enter the code sent to your phone",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // ===== BOTTOM GLASS CARD =====
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Enter 6 digit OTP",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Sent to +91 ${widget.mobileNumber}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 20),

                              // ===== OTP INPUT =====
                              Pinput(
                                controller: otpController,
                                focusNode: _pinFocusNode,
                                length: 6,
                                keyboardType: TextInputType.number,
                                autofocus: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],

                                onChanged: _validateOtp,

                                onCompleted: (pin) {
                                  if (_validateOtp(pin) && !isLoading) {
                                    FocusScope.of(context).unfocus();
                                    _verifyOtp();
                                  }
                                },

                                defaultPinTheme: PinTheme(
                                  height: 56,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                focusedPinTheme: PinTheme(
                                  height: 56,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ===== RESEND =====
                              canResendOtp
                                  ? TextButton(
                                onPressed: resendAttempts >=
                                    maxResendAttempts
                                    ? null
                                    : _resendOtp,
                                child: Text(
                                  resendAttempts >= maxResendAttempts
                                      ? "Resend limit reached"
                                      : "Resend OTP (${maxResendAttempts - resendAttempts} left)",
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                              )
                                  : Text(
                                "Resend OTP in 00:${_secondsRemaining.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                    color: Colors.white70),
                              ),

                              const SizedBox(height: 16),

                              // VERIFY BUTTON
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                  isSubmitEnabled ? _verifyOtp : null,
                                  child: const Text("Verify"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== LOADER =====
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

}




