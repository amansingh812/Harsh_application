import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pinput/pinput.dart';
import 'package:school_scout/apis/login_service.dart';
import 'package:school_scout/screens/login/login_page.dart';
import 'package:school_scout/screens/login/register_page.dart';
import 'package:school_scout/screens/reset_pin/reset_enter__mobile_screen.dart';
import 'package:school_scout/widgets/app_elevated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../apis/service/home_prefetch_service.dart';
import '../../global/global_data.dart';
import '../../widgets/brand_loader.dart';
import '../../widgets/my_bottomNavigator.dart';
import '../launch/home_loader_screen.dart';

class EnterPinScreen extends StatefulWidget {
  const EnterPinScreen({super.key, required this.mobileNumber});

  final String mobileNumber;

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController otpController = TextEditingController();
  bool isSubmitButtonEnabled = false;
  bool isLoading = false;

  final LoginService loginService = LoginService();
  VideoPlayerController? _videoController;
  late FocusNode _pinFocusNode;
  final secureStorage = const FlutterSecureStorage();

  bool _videoInitialized = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pinFocusNode = FocusNode();

    // Fade animation
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

    // Start animations immediately
    _fadeController.forward();

    // Initialize video asynchronously
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
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

      // Autofocus PIN after video loads
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted && !_pinFocusNode.hasFocus) {
          FocusScope.of(context).requestFocus(_pinFocusNode);
        }
      });
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        setState(() => _videoInitialized = false);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    otpController.dispose();
    _videoController?.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';

      final response = await loginService.loginUser(
        widget.mobileNumber,
        otpController.text,
          userId,
      );

      if (response['success'] == true) {
        final user = response['user'];

          await secureStorage.write(key: 'accessToken', value: user['authToken']);
        await secureStorage.write(key: 'refreshToken', value: user['refreshToken']);


        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user['userId']);
        await prefs.setString('phoneNumber', user['mobNumber']);
        await prefs.setString('firstName', user['firstName'] ?? '');
        await prefs.setString('lastName', user['lastName'] ?? '');
        await prefs.setString('email', user['email'] ?? '');
        await prefs.setString('gender', user['gender'] ?? '');
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isGuestUser', false);

        GlobalData().storeUserDetails(
          userId: user['userId'],
          firstName: user['firstName'],
          lastName: user['lastName'],
          email: user['email'],
          mobNumber: user['mobNumber'],
          lastLogin: user['lastLogin'],
          appVersion: user['appVersion'],
          authToken: user['authToken'],
          refreshToken: user['refreshToken'],
        );

        if (!mounted) return;

        // Success haptic
        HapticFeedback.mediumImpact();

        // Smooth navigation
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => const HomeLoaderScreen(),
            transitionsBuilder: (_, animation, __, child) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              );
              return FadeTransition(
                opacity: curvedAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                ),
              );
            },
          ),
              (route) => false,
        );
      } else {
        _handleWrongPin( 'Please enter correct PIN');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);  // Add this line
      }
      _handleWrongPin('Invalid PIN. Please try again.');
    }
  }



  void _handleWrongPin(String message) {
    if (!mounted) return;

    // Error haptic
    HapticFeedback.heavyImpact();

    setState(() {
      isLoading = false;
      isSubmitButtonEnabled = false;
    });

    // Clear PIN
    otpController.clear();

    // Refocus PIN input
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_pinFocusNode);
      }
    });

    // Show error
    _showErrorDialog(message);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
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

    if (ok) {
      HapticFeedback.selectionClick(); // Subtle feedback when complete
    }

    return ok;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goToLogin();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1847),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // ===== BACKGROUND VIDEO OR FALLBACK =====
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                switchInCurve: Curves.easeIn,
                child: _videoInitialized && _videoController != null
                    ? _buildVideoBackground()
                    : Container(
                  key: const ValueKey('fallback'),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        const Color(0xFF162E8B).withOpacity(0.95),
                        const Color(0xFF0A1847),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ===== ANIMATED DARK OVERLAY =====
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(
                      (_videoInitialized ? 0.35 : 0.2) * _fadeAnimation.value,
                    ),
                  ),
                );
              },
            ),

            // ===== FOREGROUND WITH FADE =====
            FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Stack(
                  children: [
                    // Back button with animation
                    Positioned(
                      top: 16,
                      left: 16,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _fadeController,
                            curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
                          ),
                        ),
                        child: _buildBackButton(),
                      ),
                    ),

                    // Top title with animation
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.3),
                          end: Offset.zero,
                        ).animate(_slideAnimation),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildTop(),
                        ),
                      ),
                    ),

                    // Bottom glass card with slide up
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(_slideAnimation),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: _buildBottom(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== LOADING OVERLAY (FIXED) =====
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: const Center(
                      child: BrandLoader(text: "Verifying PIN …"),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  // Smart video background that adapts to device size and video aspect ratio
  Widget _buildVideoBackground() {
    final Size screenSize = MediaQuery.of(context).size;
    final Size videoSize = _videoController!.value.size;

    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: FittedBox(
        key: const ValueKey('video'),
        fit: BoxFit.cover,
        alignment: Alignment.center,
        child: SizedBox(
          width: videoSize.width,
          height: videoSize.height,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }
  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () {
          HapticFeedback.selectionClick();
          _goToLogin();
        },
      ),
    );
  }
  void _goToLogin() async {
    // 🔥 clear everything (VERY IMPORTANT)
    await secureStorage.deleteAll();
    GlobalData().clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }
  Widget _buildTop() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Secure Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 28,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

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
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
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
          "Enter your PIN",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        _buildGreyText("Mobile number +91 ${widget.mobileNumber}"),
        const SizedBox(height: 28),
        _buildPinFormField(),
        const SizedBox(height: 24),
        _buildLoginButton(),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }

  Widget _buildPinFormField() {
    final baseDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.grey.shade300,
        width: 1.5,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Pinput(
            controller: otpController,
            focusNode: _pinFocusNode,
            autofocus: false,
            obscureText: true,
            length: 4,
            hapticFeedbackType: HapticFeedbackType.lightImpact,
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
            defaultPinTheme: PinTheme(
              height: 64,
              width: 64,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: baseDecoration,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Color(0xFF484848),
              ),
            ),
            focusedPinTheme: PinTheme(
              height: 64,
              width: 64,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: baseDecoration.copyWith(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            submittedPinTheme: PinTheme(
              height: 64,
              width: 64,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: baseDecoration.copyWith(
                color: Colors.white,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ResetEnterMobileNumberScreen(),
                ),
              );
            },
            child: Text(
              'Forgot PIN?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitButtonEnabled && !isLoading ? _loginUser : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white.withOpacity(0.5),
          disabledForegroundColor: Colors.black45,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          isLoading ? 'Verifying...' : 'Login',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}