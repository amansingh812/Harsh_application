import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:school_scout/apis/check_user_service.dart';
import 'package:school_scout/global/global_data.dart';
import 'package:school_scout/screens/login/enter_otp_screen.dart';
import 'package:school_scout/screens/login/register_page.dart';
import 'package:school_scout/widgets/app_elevated_button.dart';
import 'package:school_scout/widgets/app_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../main.dart';
import '../../widgets/brand_loader.dart';
import '../../widgets/my_bottomNavigator.dart';
import '../launch/home_loader_screen.dart';
import '../legal/legal_web_view.dart';
import 'enter_pin_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  final TextEditingController mobileNumController = TextEditingController();
  final CheckUserService checkUserService = CheckUserService();
  late final FocusNode _phoneFocusNode;

  bool isSubmitButtonEnabled = false;
  bool isLoading = false;
  bool _videoInitialized = false;
  final RegExp mobileNumberRegex = RegExp(r'^[6789]\d{9}$');
  final secureStorage = const FlutterSecureStorage();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glassBlurAnimation;

  @override
  void initState() {
    super.initState();
    analytics.logScreenView(
      screenName: "LoginPage",
    );
    _phoneFocusNode = FocusNode();

    // Fade animation for smooth UI appearance
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Glass blur animation - starts subtle, becomes more prominent
    _glassBlurAnimation = Tween<double>(
      begin: 8.0,
      end: 18.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start UI fade immediately
    _fadeController.forward();

    // Initialize video asynchronously
    _initializeVideo();

    // Preload next screen for instant navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Warm up navigation routes
      precacheImage(const AssetImage('assets/images/app_icon.png'), context);
    });
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

      // Request focus after video loads for smooth experience
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted && !_phoneFocusNode.hasFocus) {
          FocusScope.of(context).requestFocus(_phoneFocusNode);
        }
      });
    } catch (e) {
      debugPrint('Video initialization error: $e');
      // Fallback: still show UI even if video fails
      if (mounted) {
        setState(() => _videoInitialized = false);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _phoneFocusNode.dispose();
    mobileNumController.dispose();
    _videoController?.dispose();
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

      String mobileNumber = GlobalData().mobNumber.toString();

      // Call checkUser API
      final response = await checkUserService.checkUser(
        '', // role
        mobileNumber,
        '',
      );

      print('CheckUser Response: $response');

      // ❌ Network error
      if (response['type'] == 'exception') {
        if (!mounted) return;
        setState(() => isLoading = false);
        HapticFeedback.mediumImpact();
        _showErrorDialog('Network error. Please check your internet connection.');
        return;
      }

      // ✅ CASE 1: User exists with mobile → Go to PIN screen
      if (response['statusCode'] == '200' && response['mobileExists'] == true) {
        // Save userId and mobileNumber
        await prefs.setString('userId', response['userId'] ?? '');
        await prefs.setString('mobileNumber', response['mobileNumber'] ?? mobileNumber);

        if (!mounted) return;
        setState(() => isLoading = false);

        // Navigate to PIN screen
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => EnterPinScreen(
              mobileNumber: mobileNumber,
            ),
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
        );
        return;
      }

      // ✅ CASE 2 & 3: User doesn't exist OR exists without mobile → Send OTP
      if (response['statusCode'] == '500' && response['mobileExists'] == false) {

        // Send OTP via Firebase
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+91$mobileNumber',
          timeout: const Duration(seconds: 3),

          // Auto-detected OTP
          verificationCompleted: (PhoneAuthCredential credential) async {
            debugPrint("OTP auto-detected");
            // Don't auto-login
          },

          // Verification failed
          verificationFailed: (FirebaseAuthException e) {
            if (!mounted) return;
            setState(() => isLoading = false);

            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message ?? "Verification failed"),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.red.shade400,
              ),
            );
          },

          // OTP sent successfully
          codeSent: (String verificationId, int? resendToken) {
            if (!mounted) return;
            setState(() => isLoading = false);

            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (_, __, ___) => EnterOtpScreen(
                  mobileNumber: mobileNumber,
                  verificationId: verificationId,
                  resendToken: resendToken,
                ),
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
            );
          },

          codeAutoRetrievalTimeout: (_) {},
        );
        return;
      }

      // ❌ Unexpected response
      if (!mounted) return;
      setState(() => isLoading = false);
      HapticFeedback.mediumImpact();
      _showErrorDialog(
        response['message'] ?? 'Login failed. Please try again.',
      );

    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      HapticFeedback.mediumImpact();
      _showErrorDialog('An error occurred: ${e.toString()}');
    }
  }



  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return AppTextFormField(
      title: "",
      hintText: "98765 43210",
      isMobileNumberField: true,
      textEditingController: mobileNumController,
      focusNode: _phoneFocusNode,
      autofocus: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onChanged: (value) async {
        final t = value.trim();
        if (t.length <= 10) {
          setState(() => isSubmitButtonEnabled = mobileNumberRegex.hasMatch(t));
        }
        if (t.length == 10 && mobileNumberRegex.hasMatch(t)) {
          GlobalData().mobNumber = t;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('mobileNumber',t);
          HapticFeedback.selectionClick(); // Subtle feedback when complete

          FocusScope.of(context).unfocus();

        }
      },
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        if (v.trim().length < 10) return null;
        if (!mobileNumberRegex.hasMatch(v.trim())) {
          return "Please enter a valid mobile number";
        }
        return null;
      },
    );
  }
  Future<void> _handleGuestLogin() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';


      final response = await checkUserService.checkUser('Guest','',userId);

      if (response['success'] == true) {
        final List userList = response['userDetails'];
        final user = userList.first;

        // 🔐 Save tokens
        await secureStorage.write(
            key: 'accessToken', value: user['authToken']);
        await secureStorage.write(
            key: 'refreshToken', value: user['refreshToken']);

        // 💾 Save userId + guest flag

        await prefs.setString('userId', user['userId']);
        await prefs.setBool('isGuestUser', true);
        await prefs.setBool('isLoggedIn', false);

        // 📊 Analytics
        await analytics.logEvent(name: "GuestMode");

        // 🔥 Crashlytics user tag (optional but good)
        FirebaseCrashlytics.instance
            .setUserIdentifier(user['userId']);

        if (!mounted) return;

        HapticFeedback.mediumImpact();

        // 🚀 Navigate
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
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      debugPrint("Guest login error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0A1847),
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
                      _videoInitialized
                          ? 0.35 * _fadeAnimation.value
                          : 0.2 * _fadeAnimation.value
                  ),
                ),
              );
            },
          ),

          // ===== FOREGROUND UI WITH FADE =====
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Stack(
                children: [
                  // Animated Header icon (top-left)
                  Positioned(
                    top: 24,
                    left: 24,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _fadeController,
                          curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
                        ),
                      ),
                      child: const _HeaderIcon(),
                    ),
                  ),
                  // Skip Button (Top Right)
                  // Positioned widget add karo SafeArea ke andar, top-right mein

                  Positioned(
                    top: 24,
                    right: 24,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _fadeController,
                          curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          HapticFeedback.selectionClick();
                          await _handleGuestLogin();


                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),


                  // ===== BOTTOM GLASS CARD WITH ANIMATED BLUR =====
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _fadeController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: AnimatedBuilder(
                          animation: _glassBlurAnimation,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: _glassBlurAnimation.value,
                                  sigmaY: _glassBlurAnimation.value,
                                ),
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
                                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Sign in to your account",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Enter your mobile number to continue",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),

                              _buildPhoneField(),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isSubmitButtonEnabled && !isLoading
                                      ? _loginUser
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor: Colors.white.withOpacity(0.5),
                                    disabledForegroundColor: Colors.black45,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ), child:
                                 Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [


                                      if (isLoading) const SizedBox(width: 12),
                                      Text(
                                        isLoading ? "Please wait…" : "Sign In",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    "By continuing, you agree to our ",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LegalWebView(
                                            assetPath: "assets/legal/privacy_policy.html",
                                            title: "Privacy Policy",
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    " and ",
                                    style: TextStyle(color: Colors.white60, fontSize: 12),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LegalWebView(
                                            assetPath: "assets/legal/terms_and_conditions.html",
                                            title: "Terms & Conditions",
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Terms & Conditions",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Better loading overlay with blur
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.35),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: const Center(
                            child: BrandLoader(text: "Signing you in…"),
                          ),
                        ),
                      ),
                    ),

                ],
              ),
            ),
          ),
        ],
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
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
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
      child: const Icon(Icons.school, color: Colors.white, size: 28),
    );
  }
}

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

Future<void> setupPushNotifications() async {
  NotificationSettings settings = await _firebaseMessaging.requestPermission();
  String? token = await _firebaseMessaging.getToken();
  debugPrint('FCM Token: $token');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('App opened from notification: ${message.notification?.title}');
  });
}


