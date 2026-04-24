import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_scout/apis/login_service.dart';
import 'package:school_scout/screens/login/register_page.dart';
import 'package:school_scout/widgets/app_elevated_button.dart';
import 'package:school_scout/widgets/app_text_form_field.dart';
import '../../apis/service/home_prefetch_service.dart';
import '../../global/global_data.dart';
import '../../widgets/my_bottomNavigator.dart';
import 'dart:ui';                       // for ImageFilter.blur
import 'package:video_player/video_player.dart';  // for background video

class EnterPinScreen extends StatefulWidget {
  const EnterPinScreen({super.key, required this.mobileNumber});

  final String mobileNumber;

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isSubmitButtonEnabled = false;
  bool isLoading = false;
  late Size mediaSize;

  final LoginService loginService = LoginService();

  late VideoPlayerController _videoController;
  late FocusNode _pinFocusNode;


  @override
  void initState() {
    super.initState();

    _pinFocusNode = FocusNode();

    // same video as LoginPage
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

        // autofocus PIN after first frame -> open keyboard
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(_pinFocusNode);
          }
        });
      });
  }

  @override
  void dispose() {
    otpController.dispose();
    _videoController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    final prefs =  await SharedPreferences.getInstance();
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';

      final response = await loginService.loginUser(
        widget.mobileNumber,
        otpController.text,
          userId,
      );

      if (response['success']) {
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('phoneNumber', GlobalData().mobNumber.toString());
        HomePrefetchService.preload();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavigatorClass(),
          ),
        );
      } else {
        _showErrorDialog('Login failed. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Something went wrong');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool validateOtp(String pinValue) {
    final ok = pinValue.length == 4 && RegExp(r'^[0-9]+$').hasMatch(pinValue);
    setState(() => isSubmitButtonEnabled = ok);
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              // ===== BACKGROUND VIDEO =====
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
                    // Top title
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: _buildTop(),
                    ),

                    // Bottom glass card
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16,
                        ),
                        child: _buildBottom(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Full-screen loader
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3.0,
              ),
            ),
          ),
      ],
    );
  }

  // ===== TOP TITLE (same as before, just reused) =====
  Widget _buildTop() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_sharp,
            size: 45,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          Text(
            "Schools Near me",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 2,
            ),
          )
        ],
      ),
    );
  }

  // ===== BOTTOM GLASS CARD =====
  Widget _buildBottom() {
    return ConstrainedBox(
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
            // 🔥 Scroll if things don't fit (when keyboard is open)
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter your 4 digit PIN",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        _buildGreyText("For mobile number +91 ${widget.mobileNumber}"),
        const SizedBox(height: 24),

        _buildPinFormField(),

        const SizedBox(height: 24),

        _buildLoginButton(),
        const SizedBox(height: 8),

        _buildCreateAccount(),
      ],
    );
  }


  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ===== PIN WITH FULL BOXES =====
  Widget _buildPinFormField() {
    final baseDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade400,
        width: 1,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreyText("Enter PIN"),
        const SizedBox(height: 16),
        Center(
          child: Pinput(
            controller: otpController,
            focusNode: _pinFocusNode,
            autofocus: false, // focus handled in initState
            obscureText: true,
            length: 4,
            onChanged: (value) {
              final isPinValid = validateOtp(value);
              if (isPinValid) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            onCompleted: (pin) {
              if (validateOtp(pin)) {
                FocusScope.of(context).unfocus();
              }
            },
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },

            // full box style
            defaultPinTheme: PinTheme(
              height: 56,
              width: 56,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: baseDecoration,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF484848),
              ),
            ),
            focusedPinTheme: PinTheme(
              height: 56,
              width: 56,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: baseDecoration.copyWith(
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
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            submittedPinTheme: PinTheme(
              height: 56,
              width: 56,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: baseDecoration.copyWith(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Forgot Password?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return AppElevatedButton(
      onPressed: isSubmitButtonEnabled && !isLoading ? _loginUser : null,
      text: 'Login',
    );
  }

  Widget _buildCreateAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RegisterPage(),
              ),
            );
          },
          child: const Text(
            "Don't have an account? Sign up here",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}



//
