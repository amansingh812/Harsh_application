import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pinput/pinput.dart';
import 'package:school_scout/global/global_data.dart';
import 'package:school_scout/screens/login/enter_pin_screen.dart';
import 'package:school_scout/widgets/app_elevated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apis/login_service.dart';
import '../../apis/registeration_service.dart';
import '../../widgets/brand_loader.dart';
import '../../widgets/my_bottomNavigator.dart';
import '../launch/home_loader_screen.dart';
import 'login_page.dart';
import 'dart:ui'; // for ImageFilter.blur
import 'package:video_player/video_player.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>  with SingleTickerProviderStateMixin{
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

  final FocusNode _createPinFocus = FocusNode();
  final FocusNode _confirmPinFocus = FocusNode();

  bool _videoInitialized = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;


  void _updateSubmitState() {
    final ok = _isValidPin(passwordController.text) &&
        passwordController.text == confirmPasswordController.text;
    if (isSubmitButtonEnabled != ok) {
      setState(() => isSubmitButtonEnabled = ok);
    }
  }

/*  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    String mobNumber = GlobalData().mobNumber.toString();
    setState(() => isLoading = true);
    try {
      final response = await _registrationService.registerUser(
        '', // TODO
        mobNumber,
          passwordController.text.trim(),
       // TODO

      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (response['success'] == true && response['mobileExists'] == true) {
        await _safeExit();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', response['userId'] ?? '');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnterPinScreen(mobileNumber: mobNumber),
          ),
        );
      } else {
        _handlePinError('Registration failed, please try again.');
      }

    } catch (e) {
      _handlePinError('Something went wrong, please try again.');
    }

  }*/

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    String mobNumber = GlobalData().mobNumber.toString();
    String pin = passwordController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    setState(() => isLoading = true);

    try {
      final response = await _registrationService.registerUser(
        userId,
        mobNumber,
        pin,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      print('📝 Registration Response: $response');

      // ✅ SUCCESS - User registered
      if (response['success'] == true && response['mobileExists'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', response['userId'] ?? '');

        // 🔥 NOW LOGIN THE USER DIRECTLY WITH THE PIN
        await _loginUserAfterRegistration(mobNumber, pin, response['userId'] ?? '');

      } else {
        _handlePinError('Registration failed, please try again.');
      }

    } catch (e) {
      setState(() => isLoading = false);
      _handlePinError('Something went wrong, please try again.');
    }
  }

// 🔥 NEW: Auto-login after registration
  Future<void> _loginUserAfterRegistration(
      String mobNumber,
      String pin,
      String userId,
      ) async {
    setState(() => isLoading = true);

    try {
      final loginService = LoginService();

      final response = await loginService.loginUser(
        mobNumber,
        pin,
        userId,
      );

      print('🔐 Auto-login Response: $response');

      if (response['success'] == true) {
        final user = response['user'];

        // Validate required fields
        if (user['userId'] == null) {
          _handlePinError('Login failed');
          return;
        }

        final secureStorage = const FlutterSecureStorage();

        // 🔐 Store tokens
        await secureStorage.write(
          key: 'accessToken',
          value: user['authToken'],
        );
        await secureStorage.write(
          key: 'refreshToken',
          value: user['refreshToken'] ?? '',
        );

        // 💾 Store user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user['userId']);
        await prefs.setString('phoneNumber', user['mobNumber'] ?? mobNumber);
        await prefs.setString('firstName', user['firstName'] ?? '');
        await prefs.setString('lastName', user['lastName'] ?? '');
        await prefs.setString('email', user['email'] ?? '');
        await prefs.setString('gender', user['gender'] ?? '');
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isGuestUser', false);

        // 🌐 Update GlobalData
        GlobalData().storeUserDetails(
          userId: user['userId'],
          firstName: user['firstName'] ?? '',
          lastName: user['lastName'] ?? '',
          email: user['email'] ?? '',
          mobNumber: user['mobNumber'] ?? mobNumber,
          lastLogin: user['lastLogin'] ?? '',
          appVersion: user['appVersion'] ?? '',
          authToken: user['authToken'],
          refreshToken: user['refreshToken'] ?? '',
        );

        if (!mounted) return;

        // Success haptic
        HapticFeedback.mediumImpact();

        // 🔥 SAFE EXIT - Pause video first, then navigate
        if (_videoController.value.isPlaying) {
          await _videoController.pause();
        }

        if (!mounted) return;

        // 🚀 Navigate to Home (video will be disposed automatically)
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => const HomeLoaderScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          ),
              (route) => false,
        );

      } else {
        // Login failed - go to PIN screen
        setState(() => isLoading = false);

        if (_videoController.value.isPlaying) {
          await _videoController.pause();
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EnterPinScreen(mobileNumber: mobNumber),
          ),
        );
      }

    } catch (e) {
      print('❌ Auto-login error: $e');
      setState(() => isLoading = false);

      // Fallback - go to PIN screen
      if (_videoController.value.isPlaying) {
        await _videoController.pause();
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EnterPinScreen(mobileNumber: mobNumber),
        ),
      );
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
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(
      'assets/videos/Video_Resized_For_Mobile_App.mp4',
    );

    await _videoController.initialize();
    if (!mounted) return;

    setState(() => _videoInitialized = true);

    _videoController
      ..setLooping(true)
      ..setVolume(0.0)
      ..play();
  }

  /*@override
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
  }*/

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    _videoController.dispose();
    _fadeController.dispose();
    _createPinFocus.dispose();
    _confirmPinFocus.dispose();
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
    return WillPopScope(
        onWillPop: () async {
          await _safeExit();
          return true;
        },
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              child: _videoInitialized
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
                        child: _buildRegisterBottom(),
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
                    child: BrandLoader(text: "Setting up your account…",),
                  ),
                ),
              ),
            ),
        ],

      ),
        ),
    );
  }
  String _getLoadingText() {
    // You can add a state variable to track this
    // For now, generic message
    return "Setting up your account…";
  }
  Widget _buildVideoBackground() {
    final Size screen = MediaQuery.of(context).size;
    final Size video = _videoController.value.size;

    return SizedBox(
      width: screen.width,
      height: screen.height,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: video.width,
          height: video.height,
          child: VideoPlayer(_videoController),
        ),
      ),
    );
  }
  Widget _buildRegisterBottom() {
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: _buildYourExistingForm(),
          ),
        ),
      ),
    );
  }
  Widget _buildYourExistingForm() {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pill
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    "Get Started",
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

          const Text(
            "Create your account",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Join thousands of parents finding the best schools",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 22),

          _label("Create 4-digit PIN"),
          const SizedBox(height: 14),

          Center(
            child: Pinput(
              controller: passwordController,
              focusNode: _createPinFocus,
              length: 4,
              obscureText: true,
              keyboardType: TextInputType.number,
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

          const SizedBox(height: 18),

          _label("Confirm PIN"),
          const SizedBox(height: 14),

          Center(
            child: Pinput(
              controller: confirmPasswordController,
              focusNode: _confirmPinFocus,
              length: 4,
              obscureText: true,
              keyboardType: TextInputType.number,
              defaultPinTheme: _basePinTheme(context),
              focusedPinTheme: _focusedPinTheme(context),
              submittedPinTheme: _focusedPinTheme(context),
              errorPinTheme: _errorPinTheme(),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _updateSubmitState(),
              onCompleted: (_) => _registerUser(),
              validator: (value) {
                if (value == null || value.length != 4) {
                  return "Re-enter PIN";
                }
                if (value != passwordController.text) {
                  HapticFeedback.lightImpact();
                  confirmPasswordController.clear();
                  Future.microtask(() {
                    FocusScope.of(context).requestFocus(_confirmPinFocus);
                  });
                  return "PINs do not match";
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: AppElevatedButton(
              onPressed: isSubmitButtonEnabled && !isLoading ? _registerUser : null,
              text: isLoading ? "Please wait…" : "Create account",
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withOpacity(0.4))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Already have an account?",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: Colors.white.withOpacity(0.4))),
            ],
          ),

          const SizedBox(height: 12),

          Center(
            child: TextButton(
              onPressed: () async {
                await _safeExit();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text(
                "Sign in →",
                style: TextStyle(color: Colors.white),
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
  void _handlePinError(String message) {
    if (!mounted) return;

    setState(() {
      isLoading = false;
      isSubmitButtonEnabled = false;
    });

    // 🔄 Clear both PINs
    passwordController.clear();
    confirmPasswordController.clear();

    // ⌨️ Focus back to Create PIN
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_createPinFocus);
      }
    });

    // 📳 Haptic feedback
    HapticFeedback.lightImpact();

    // ❌ Show error
    _showError(message);
  }

  Future<void> _safeExit() async {
    try {
      if (_videoInitialized && _videoController.value.isInitialized) {
        if (_videoController.value.isPlaying) {
          await _videoController.pause();
        }
      }
    } catch (e) {
      debugPrint('Video cleanup error: $e');
    }
  }


}


