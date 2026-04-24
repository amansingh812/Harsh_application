import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:school_scout/screens/login/register_page.dart';

import '../../widgets/brand_loader.dart';
import '../../widgets/my_bottomNavigator.dart';
// for ImageFilter.blur
import 'package:video_player/video_player.dart';  // for background video



class EnterOtpScreen extends StatefulWidget {
  const EnterOtpScreen({
    super.key,
    required this.mobileNumber,
    required this.verificationId,
    required this.resendToken,
  });

  final String mobileNumber;
  final String verificationId;
  final int? resendToken;


  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen>  with SingleTickerProviderStateMixin {
  final TextEditingController otpController = TextEditingController();
  late FocusNode _pinFocusNode = FocusNode();

  bool isLoading = false;
  bool isSubmitEnabled = false;
  bool canResendOtp = false;

  int _secondsRemaining = 60;
  Timer? _timer;
  int resendAttempts = 0;
  static const int maxResendAttempts = 3;
  late String _verificationId; // mutable
  int? _resendToken;

  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;



/*  @override
  void initState() {
    super.initState();


    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;

    _startResendTimer();

    Future.delayed(const Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_pinFocusNode);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }*/
  @override
  void initState() {
    super.initState();

    _pinFocusNode = FocusNode();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();
    _initializeVideo();

    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;

    _startResendTimer();
  }



  @override
  void dispose() {
    otpController.dispose();
    _pinFocusNode.dispose();
    _timer?.cancel();


    super.dispose();
  }
  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(
      'assets/videos/Video_Resized_For_Mobile_App.mp4',
    );

    await _videoController!.initialize();
    if (!mounted) return;

    setState(() => _videoInitialized = true);

    _videoController!
      ..setLooping(true)
      ..setVolume(0.0)
      ..play();

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_pinFocusNode);
      }
    });
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      otpController.clear();
      FocusScope.of(context).requestFocus(_pinFocusNode);
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
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              child: _videoInitialized && _videoController != null
                  ? _buildVideoBackground()
                  : Container(color: Colors.black),
            ),
          ),

          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_slideAnimation),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: _buildOtpBottom(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: const Center(
                    child: BrandLoader(text: "Verifying OTP…"),
                  ),
                ),
              ),
            ),
        ],
      ),

    );
  }
  Widget _buildOtpBottom() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Verify OTP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sent to +91 ${widget.mobileNumber}",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 28),

              _buildOtpField(),

              const SizedBox(height: 20),
              _buildResend(),

              const SizedBox(height: 20),
              _buildVerifyButton(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildOtpField() {
    return Pinput(
      controller: otpController,
      focusNode: _pinFocusNode,
      length: 6,
      keyboardType: TextInputType.number,
      onChanged: _validateOtp,
      onCompleted: (_) => _verifyOtp(),

      defaultPinTheme: PinTheme(
        height: 64,
        width: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
  Widget _buildVideoBackground() {
    final Size screenSize = MediaQuery.of(context).size;
    final Size videoSize = _videoController!.value.size;

    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: videoSize.width,
          height: videoSize.height,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }
  Widget _buildResend() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: canResendOtp
          ? TextButton(
        key: const ValueKey("resend"),
        onPressed: _resendOtp,
        child: const Text(
          "Resend OTP",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : Text(
        "Resend OTP in 00:${_secondsRemaining.toString().padLeft(2, '0')}",
        key: const ValueKey("timer"),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),
    );
  }
  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitEnabled && !isLoading ? _verifyOtp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white.withOpacity(0.5),
          disabledForegroundColor: Colors.black45,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Verify",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

}




