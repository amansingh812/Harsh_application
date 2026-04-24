import 'dart:async';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apis/security/app_update_service.dart';
import '../../apis/service/master_sync_service.dart';
import '../../apis/service/push_service.dart';
import '../../global/global_data.dart';
import '../launch/home_loader_screen.dart';
import '../login/enter_pin_screen.dart';
import '../login/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool isVisible = true;
  final secureStorage = const FlutterSecureStorage();
  bool _nextIsHome = false;

  late AnimationController _pulseController;
  late AnimationController _contentController;
  late AnimationController _glowController;
  late AnimationController _progressController;

  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoFadeAnim;
  late Animation<Offset> _titleSlideAnim;
  late Animation<double> _titleFadeAnim;
  late Animation<double> _subtitleFadeAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    // Smooth breathing pulse for logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Content stagger animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Glow pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Progress bar animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Logo animations with stagger
    _logoScaleAnim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );

    _logoFadeAnim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    // Title animations
    _titleSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
    ));

    _titleFadeAnim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );

    // Subtitle animation
    _subtitleFadeAnim = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
    );

    // Glow animation
    _glowAnim = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    // Progress animation
    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutQuart,
    );

    _startApp();
  }

  Future<void> _startApp() async {
    try {
      // Start animations immediately
      _contentController.forward();

      // Start progress bar animation
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _progressController.forward();
      }

      // Check login status quickly (only read, no heavy operations)
      final prefs = await SharedPreferences.getInstance();
     /* final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final token = await secureStorage.read(key: 'accessToken');

      _nextIsHome = token != null && token.isNotEmpty && isLoggedIn;*/
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final isGuestUser = prefs.getBool('isGuestUser') ?? false;
      final token = await secureStorage.read(key: 'accessToken');

      _nextIsHome =
          token != null &&
              token.isNotEmpty &&
              (isLoggedIn || isGuestUser);


      print("✅ Login check complete: $_nextIsHome");

      // Wait for progress animation to complete
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        _navigateToNext();
      }

      // 🚀 Do ALL heavy work AFTER navigation
      _warmUpApp();
    } catch (e) {
      print("❌ Splash screen error: $e");
      // Still navigate even if there's an error
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 1800));
        _navigateToNext();
      }
    }
  }

  Future<void> _warmUpApp() async {
    // This runs AFTER navigation, so it won't block the splash screen
    try {
      print("🔧 Starting background initialization...");

      // Load user data
      final prefs = await SharedPreferences.getInstance();
      GlobalData().city = prefs.getString('city') ?? 'Bangalore';
      GlobalData().pincode = prefs.getString('pincode') ?? '560001';
      GlobalData().firstName = prefs.getString('firstName');
      GlobalData().lastName = prefs.getString('lastName');
      GlobalData().email = prefs.getString('email');
      GlobalData().mobNumber = prefs.getString('phoneNumber');

      print("✅ GlobalData loaded");

      // Initialize push notifications (non-blocking)
      PushService.initializeAll().then((_) {
        print("✅ Push service initialized");
      }).catchError((e) {
        print("❌ Push service error: $e");
      });

      // Request App Tracking Transparency (iOS only)
      if (Platform.isIOS) {
        await Future.delayed(const Duration(seconds: 2));
        final status = await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await AppTrackingTransparency.requestTrackingAuthorization();
          print("✅ ATT requested");
        }
      }

      // Check for app updates (Android only)
      if (Platform.isAndroid) {
        AppUpdateService.checkAndUpdate().then((_) {
          print("✅ App update check complete");
        }).catchError((e) {
          print("❌ App update check error: $e");
        });
      }

      // Sync master data (non-blocking)
      MasterSyncService.sync().then((_) {
        print("✅ Master data synced");
      }).catchError((e) {
        print("❌ Master sync error: $e");
      });

      print("✅ Background initialization complete");
    } catch (e) {
      print("❌ Warm-up error: $e");
    }
  }

  void _navigateToNext() {
    if (!mounted) return;

    print("🚀 Navigating to: ${_nextIsHome ? 'Home' : 'Login'}");

    // Navigate immediately with slide-up transition
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
        _nextIsHome ? const HomeLoaderScreen() : const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Curved animation for smoother feel
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );

          // Current splash screen slides up
          final splashSlide = Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0, -1),
          ).animate(curvedAnimation);

          // New screen slides up from bottom
          final newScreenSlide = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation);

          return Stack(
            children: [
              // Old screen sliding up
              SlideTransition(
                position: splashSlide,
                child: Scaffold(
                  backgroundColor: const Color(0xFF162E8B),
                  body: Stack(
                    children: [
                      Container(
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
                    ],
                  ),
                ),
              ),
              // New screen sliding up
              SlideTransition(
                position: newScreenSlide,
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _contentController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF162E8B),
      body: Stack(
        children: [
          // Subtle gradient background
          Container(
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

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with enhanced animations
                FadeTransition(
                  opacity: _logoFadeAnim,
                  child: ScaleTransition(
                    scale: _logoScaleAnim,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_pulseController, _glowAnim]),
                      builder: (_, child) {
                        final breathScale = 1 + (_pulseController.value * 0.025);
                        final glowIntensity = 0.15 + (_glowAnim.value * 0.15);

                        return Transform.scale(
                          scale: breathScale,
                          child: Container(
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF2A900).withOpacity(glowIntensity),
                                  blurRadius: 60 + (_glowAnim.value * 30),
                                  spreadRadius: 10 + (_glowAnim.value * 15),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.asset(
                                'assets/images/app_icon.png',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title with slide and fade
                SlideTransition(
                  position: _titleSlideAnim,
                  child: FadeTransition(
                    opacity: _titleFadeAnim,
                    child: Column(
                      children: [
                        const Text(
                          'SCHOOL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            height: 1.1,
                          ),
                        ),
                        const Text(
                          'SCOUT',
                          style: TextStyle(
                            color: Color(0xFFF2A900),
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 64,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF2A900),
                                Color(0xFFFFD700),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF2A900).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle with fade
                FadeTransition(
                  opacity: _subtitleFadeAnim,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Your Trusted Companion in Finding the Perfect School',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom progress bar
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 160,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, __) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressAnim.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF2A900),
                              Color(0xFFFFD700),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF2A900).withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}