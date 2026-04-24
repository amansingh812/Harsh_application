import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_scout/apis/check_user_service.dart';
import 'package:school_scout/global/global_data.dart';
import 'package:school_scout/screens/login/enter_otp_screen.dart';
import 'package:school_scout/screens/login/register_page.dart';
import 'package:school_scout/screens/reset_pin/reset_enter_otp_screen.dart';
import 'package:school_scout/widgets/app_elevated_button.dart';
import 'package:school_scout/widgets/app_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../widgets/my_bottomNavigator.dart';



class ResetEnterMobileNumberScreen extends StatefulWidget {
  const ResetEnterMobileNumberScreen({super.key});

  @override
  State<ResetEnterMobileNumberScreen> createState() => _ResetEnterMobileNumberScreenState();
}

class _ResetEnterMobileNumberScreenState extends State<ResetEnterMobileNumberScreen> {
  late VideoPlayerController _videoController;
  final TextEditingController mobileNumController = TextEditingController();
  final CheckUserService checkUserService = CheckUserService();
  late final FocusNode _phoneFocusNode;

  bool isSubmitButtonEnabled = false;
  bool isLoading = false;
  final RegExp mobileNumberRegex = RegExp(r'^[6789]\d{9}$');

  late Size mediaSize;


  @override
  void initState() {
    super.initState();

    _phoneFocusNode = FocusNode();

    _videoController = VideoPlayerController.asset(
      'assets/videos/Video_Resized_For_Mobile_App.mp4',
    )
      ..initialize().then((_) {
        if (!mounted) return;

        debugPrint('VIDEO INITIALIZED: ${_videoController.value.size}');
        _videoController
          ..setLooping(true)
          ..setVolume(0.0)
          ..play();

        setState(() {}); // so the video actually appears

        // ✅ After the first frame, request focus = open keyboard
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(_phoneFocusNode);
          }
        });
      });
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    mobileNumController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  // === Validation ===
  bool _validatePhoneNumber(String phone) {
    final ok = mobileNumberRegex.hasMatch(phone);
    setState(() => isSubmitButtonEnabled = ok);
    return ok;
  }

  // === Flow unchanged; just triggered from Sign In ===
  Future<void> _loginUser() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';
      String mobileNumber = prefs.getString('mobileNumber') ?? '';


      final response = await checkUserService.checkUser(
          '',mobileNumber,''
      );


      if (response['mobileExists'] == true) {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+91${GlobalData().mobNumber}',
          timeout: const Duration(seconds: 3),

          // 📱 AUTO-READ OTP
         /* verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const BottomNavigatorClass(),
              ),
            );
          }*/verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint("OTP auto-detected for PIN reset");
          // Do NOT sign in
          // Do NOT navigate
        }
          ,

          verificationFailed: (FirebaseAuthException e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? "Verification failed")),
            );
          },

          // 📩 OTP SENT
          codeSent: (String verificationId, int? resendToken) {
            setState(() => isLoading = false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ResetEnterOtpScreen(
                      mobileNumber: GlobalData().mobNumber.toString(),
                      verificationId: verificationId,
                      resendToken: resendToken, // 🔥 IMPORTANT
                    ),
              ),
            );
          },

          codeAutoRetrievalTimeout: (_) {},
        );
      }

      else {
        _showErrorDialog('Please try again after some time.');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text('OK')),
            ],
          ),
    );
  }
  Widget _buildPhoneField() {
    return AppTextFormField(
      title: "",                        // we already show text above
      hintText: "98765 43210",
      isMobileNumberField: true,
      textEditingController: mobileNumController,
      focusNode: _phoneFocusNode,       // 👈 important
      autofocus: false,                 // focus is via requestFocus
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onChanged: (value) async {
        final t = value.trim();
        if (t.length <= 10) {
          setState(() =>
          isSubmitButtonEnabled = mobileNumberRegex.hasMatch(t));
        }
        if (t.length == 10 && mobileNumberRegex.hasMatch(t)) {
          GlobalData().mobNumber = t;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('mobileNumber',t);

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

/*  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;

    final purple = const Color(0xFF9C6BFF); // soft purple to match mock
    final lightPurple = const Color(0xFFF3EFFF);
    final double cardTop =
    (mediaSize.height * 0.26).clamp(180.0, 320.0);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [purple, Colors.white],
            stops: const [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Skip
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BottomNavigatorClass()),
                  ),
                  child: const Text(
                    "Skip for now",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              // Header (logo + title + subtitle)
              Positioned(
                top: cardTop,                       // responsive gap
                left: 16,
                right: 16,
                bottom: 12,                         // leaves room for footer
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                      ),
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          child: _CardContents(lightPurple: lightPurple),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Card
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: lightPurple,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.auto_awesome, size: 16, color: Color(0xFF7F56D9)),
                                SizedBox(width: 6),
                                Text("Welcome Back", style: TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Sign in to your account",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Continue exploring schools in your area",
                            style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.2),
                          ),
                          const SizedBox(height: 24),

                          // Label
                          const Text(
                            "Mobile number",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 8),

                          // Mobile input (NO 4-digit PIN)
                          AppTextFormField(
                            title: "Mobile number",
                            hintText: "Enter your mobile number",
                            textEditingController: mobileNumController, // ✅ correct prop
                            isMobileNumberField: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            onChanged: (value) {
                              final trimmed = value.trim();
                              if (trimmed.length <= 10) {
                                _validatePhoneNumber(trimmed);
                              }
                              if (trimmed.length == 10 && mobileNumberRegex.hasMatch(trimmed)) {
                                GlobalData().mobNumber = trimmed;
                                FocusManager.instance.primaryFocus?.unfocus();
                              }
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return null;
                              if (value.trim().length < 10) return null;
                              if (!mobileNumberRegex.hasMatch(value.trim())) {
                                return "Please enter a valid mobile number";
                              }
                              return null;
                            },
                            inputFormatters:  [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),


                          const SizedBox(height: 24),

                          // Sign In button
                          AppElevatedButton(
                            onPressed: isSubmitButtonEnabled && !isLoading ? _loginUser : null,
                            text: isLoading ? 'Please wait…' : 'Sign In',
                          ),

                          const SizedBox(height: 8),

                          // Create account
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => RegisterPage()),
                                );
                              },
                              child: const Text("Create an account →"),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Footer fine print
              Positioned(
                bottom: 8,
                left: 16,
                right: 16,
                child: Opacity(
                  opacity: 0.8,
                  child: Text(
                    "By continuing, you agree to our Terms of Service and Privacy Policy",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  // ... (imports and state class definition remain the same)


// ... (imports and state class definition remain the same)

  // ... (imports remain the same)

  // ... (controllers and methods remain the same)
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black, // fallback while video loads
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
                : Container(color: Colors.black), // show black until init
          ),

          // ===== DARK OVERLAY =====
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          // ===== FOREGROUND UI =====
          SafeArea(
            child: Stack(
              children: [
                // Skip button
              /*  Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BottomNavigatorClass(),
                      ),
                    ),
                    child: const Text(
                      "Skip for now",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),*/

                // Header icon (top-left)
                const Positioned(
                  top: 24,
                  left: 24,
                  child: _HeaderIcon(),
                ),

                // ===== BOTTOM GLASS CARD =====
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Reset PIN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Enter your registered mobile number",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // AppTextFormField with focus node
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 12,
                                    ),
                                    shape: const StadiumBorder(),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    isLoading ? "Please wait…" : "Sending OTP",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
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

                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.2),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }



}



// ... (_HeaderIcon remains the same)


// Helper widget for the header icon to keep the build method cleaner
class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.school, color: Colors.white, size: 28),
    );
  }



}

// ==== (optional) push notification setup unchanged ====
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
class _CardContents extends StatelessWidget {
  const _CardContents({required this.lightPurple});
  final Color lightPurple;

  @override
  Widget build(BuildContext context) {
    // put your existing column here unchanged
    // (Welcome Back pill → Sign in → Mobile number field → Sign In button → Create account)
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ... your current contents ...
      ],
    );
  }

}

