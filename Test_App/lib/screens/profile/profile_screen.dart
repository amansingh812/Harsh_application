import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:dotted_separator/dotted_separator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';

import 'package:school_scout/global/global_data.dart';
import 'package:school_scout/screens/child_profile/add_child_profile.dart';
import 'package:school_scout/screens/legal/privacy_policy_screen.dart';
import 'package:school_scout/screens/profile/edit_profile_screen.dart';
import 'package:school_scout/screens/login/login_page.dart';
import 'package:school_scout/screens/profile/profile_about_screen.dart';
import 'package:school_scout/screens/profile/update_pin_screen.dart';
import 'package:school_scout/screens/shortlist/shortlisted_school.dart';
import 'package:school_scout/screens/child_profile/show_child_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../apis/service/delete_account_service.dart';
import '../../config/version_screen.dart';
import '../../global/global_data.dart';
import '../../main.dart';
import '../../themes/app_colors.dart';
import '../../widgets/banner_ad_widget.dart';
import '../launch/home_loader_screen.dart';
import '../legal/legal_web_view.dart';
import '../legal/terms_and_conditions.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _secureStorage = const FlutterSecureStorage();
  late AnimationController _animationController;
  bool _isGuest = false; // ✅ State variable
  bool _isLoading = true; // ✅ Loading state
  bool _isLoggingOut = false;

  String get _userName {
    final first = GlobalData().firstName?.trim().isNotEmpty == true
        ? GlobalData().firstName!
        : 'User';

    final last = GlobalData().lastName?.trim().isNotEmpty == true
        ? GlobalData().lastName!
        : '';

    return '$first $last'.trim();
  }



  @override
  void initState() {
    super.initState();
    analytics.logScreenView(
      screenName: "ProfileScreen",
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();
    _loadGuestStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ✅ Load from SharedPreferences
  Future<void> _loadGuestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGuest = prefs.getBool('isGuestUser') ?? false;
      _isLoading = false;
    });
  }
/*  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== TOP HEADER CARD =====
              _buildProfileHeaderCard(colorScheme),

              const SizedBox(height: 28),

              // ===== MY ACCOUNT SECTION =====
              _buildSectionTitle("MY ACCOUNT"),
              const SizedBox(height: 10),
              _buildSectionCard(
                children: [
                  _buildMenuItem(
                    Icons.person_4_outlined,
                    "Tell us about yourself",
                    "Personal details",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileAboutScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.person_2_outlined,
                    "Child Profile",
                    "Manage child information",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShowChildDetails(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.favorite_border_outlined,
                    "Shortlisted Schools",
                    "View shortlisted schools",
                    onTap: () {
                      bottomNavKey.currentState?.goToTab(4);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ===== SUPPORT SECTION =====
              _buildSectionTitle("SUPPORT"),
              const SizedBox(height: 10),
              _buildSectionCard(
                children: [
                  _buildMenuItem(
                    Icons.headphones_outlined,
                    "Need Help?",
                    "Contact support",
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalWebView(
                            assetPath: "assets/legal/support.html",
                            title: "Support",
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.star_border,
                    "Rate Our App",
                    "Share your feedback",
                    onTap: () async {
                      final Uri url = Platform.isAndroid
                          ? Uri.parse(
                        "https://play.google.com/store/apps/details?id=com.techhub.schoolScout",
                      ) // 👈 ANDROID: apna package name
                          : Uri.parse(
                        "https://apps.apple.com/app/id6758800903?action=write-review",
                      ); // 👈 iOS: apna APP STORE ID

                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),


                ],
              ),

              const SizedBox(height: 28),
// ===== ABOUT SECTION ===== (Terms, Privacy, Delete Account, Version)
              _buildSectionTitle("ABOUT"),
              const SizedBox(height: 10),
              _buildSectionCard(
                children: [

                  _buildMenuItem(
                    Icons.edit_document,
                    "Terms and Conditions",
                    "Read our terms",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalWebView(
                            assetPath: "assets/legal/terms_and_conditions.html",
                            title: "Terms and Conditions",
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.privacy_tip_outlined,
                    "Privacy Policy",
                    "How we use your data",
                    onTap: () {
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
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.delete_forever_outlined,
                    "Delete Account",
                    "Permanently remove your account",
                    isDestructive: true,
                    onTap: () {
                      _showDeleteAccountConfirmation(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ===== LOGOUT BUTTON CARD =====
              _buildSectionCard(
                children: [
                  _buildMenuItem(
                    Icons.logout_outlined,
                    "Logout",
                    "Sign out from your account",
                    isDestructive: true,
                    onTap: () {
                      _showLogoutConfirmation(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 24, left: 24),
                child: const VersionScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        // ✅ Show loading while fetching prefs
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final prefs = snapshot.data!;
        final isGuest = prefs.getBool('isGuestUser') ?? false;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  isGuest
                      ? _buildGuestHeader(colorScheme)
                      : _buildProfileHeaderCard(colorScheme),

                  const SizedBox(height: 28),

                  // AD 1
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: BannerAdWidget(),
                  ),
                  const SizedBox(height: 28),

                  // Sign-in prompt for guests
                  if (isGuest) ...[
                    _buildSignInPromptCard(colorScheme),
                    const SizedBox(height: 28),
                  ],

                  // MY ACCOUNT (only for logged in)
                  if (!isGuest) ...[
                    _buildSectionTitle("MY ACCOUNT"),
                    const SizedBox(height: 10),
                    _buildSectionCard(
                      children: [
                        _buildMenuItem(
                          Icons.person_4_outlined,
                          "Tell us about yourself",
                          "Personal details",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileAboutScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          Icons.person_2_outlined,
                          "Child Profile",
                          "Manage child information",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ShowChildDetails(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          Icons.favorite_border_outlined,
                          "Shortlisted Schools",
                          "View shortlisted schools",
                          onTap: () {
                            bottomNavKey.currentState?.goToTab(4);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],

                  // SUPPORT SECTION
                  _buildSectionTitle("SUPPORT"),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    children: [
                      _buildMenuItem(
                        Icons.headphones_outlined,
                        "Need Help?",
                        "Contact support",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LegalWebView(
                                assetPath: "assets/legal/support.html",
                                title: "Support",
                              ),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Icons.star_border,
                        "Rate Our App",
                        "Share your feedback",
                        onTap: () async {
                          final Uri url = Platform.isAndroid
                              ? Uri.parse(
                            "https://play.google.com/store/apps/details?id=com.techhub.schoolScout",
                          )
                              : Uri.parse(
                            "https://apps.apple.com/app/id6758800903?action=write-review",
                          );

                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                 /* // AD 2
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: BannerAdWidget(),
                  ),
                  const SizedBox(height: 28),*/

                  // ABOUT SECTION
                  _buildSectionTitle("ABOUT"),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    children: [
                      _buildMenuItem(
                        Icons.edit_document,
                        "Terms and Conditions",
                        "Read our terms",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LegalWebView(
                                assetPath: "assets/legal/terms_and_conditions.html",
                                title: "Terms and Conditions",
                              ),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Icons.privacy_tip_outlined,
                        "Privacy Policy",
                        "How we use your data",
                        onTap: () {
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
                      ),

                      if (!isGuest) ...[
                        _buildDivider(),
                        _buildMenuItem(
                          Icons.delete_forever_outlined,
                          "Delete Account",
                          "Permanently remove your account",
                          isDestructive: true,
                          onTap: () {
                            _showDeleteAccountConfirmation(context);
                          },
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 28),

                  // LOGOUT/EXIT BUTTON
                  _buildSectionCard(
                    children: [
                      _buildMenuItem(
                        isGuest ? Icons.exit_to_app : Icons.logout_outlined,
                        isGuest ? "Exit Guest Mode" : "Logout",
                        isGuest
                            ? "Return to login screen"
                            : "Sign out from your account",
                        isDestructive: true,
                        onTap: () {
                          if (isGuest) {
                            _showExitGuestConfirmation(context);
                          } else {
                            _showLogoutConfirmation(context);
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // AD 3
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: BannerAdWidget(),
                  ),
                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 24, left: 24),
                    child: VersionScreen(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildGuestHeader(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Row(
        children: [
          // Guest avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.7),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),

          // Guest text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Guest User",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Browsing without an account",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInPromptCard(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_person_outlined,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            "Sign in to unlock all features",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            "Save schools, manage profiles, and get personalized recommendations",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              child: const Text(
                "Sign In Now",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitGuestConfirmation(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.exit_to_app,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                "Exit Guest Mode?",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                "You'll return to the login screen",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                       // await clearAll();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                              (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Exit",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildProfileHeaderCard(ColorScheme colorScheme) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
          .animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        child: Row(
          children: [
            // Avatar with enhanced styling
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.7),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/man.png'),
                radius: 36,
              ),
            ),
            const SizedBox(width: 16),
            // Name + "View profile"
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "View full profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: !_isLoggingOut,
      enableDrag: !_isLoggingOut,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Sign out from your account?",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "You can sign in again anytime",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                          _isLoggingOut ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoggingOut
                              ? null
                              : () async {
                            setModalState(() => _isLoggingOut = true);
                            await _logoutUser(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                          child: _isLoggingOut
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            "Sign Out",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logoutUser(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 400));

    clearAll();
    Navigator.pop(context);

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
          (route) => false,
    );
  }

  Future<void> clearAll() async {
    try {
      // 1. Clear Secure Storage
      await _secureStorage.deleteAll();

      // 2. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Clear Hive boxes (only clear, don't close)
      final schoolBox = Hive.box('schools');
      final masterBox = Hive.box('masterData');
      final shortlistBox = Hive.box('shortlist');

      await schoolBox.clear();
      await masterBox.clear();
      await shortlistBox.clear();

      // 4. Reset GlobalData
      GlobalData().reset();

      debugPrint('✅ Logout: All data cleared');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // SECTIONS
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MENU ITEM
  // ---------------------------------------------------------------------------

  Widget _buildMenuItem(
      IconData icon,
      String title,
      String subtitle, {
        required VoidCallback onTap,
        bool isDestructive = false,
      }) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDestructive ? Colors.red : primary;
    final Color titleColor =
    isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black87);
    final bgColor = isDestructive
        ? Colors.red.withOpacity(0.1)
        : isDark
        ? primary.withOpacity(0.15)
        : const Color(0xFFF0F4FF);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: iconColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showDeleteAccountConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Warning Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),

              Text(
                "Delete Account?",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ✅ CENTERED & CLEAN CONTENT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    Text(
                      "This will permanently delete:",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Bullet points - centered
                    _buildCenteredDeletePoint(
                      "All your personal data",
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildCenteredDeletePoint(
                      "Shortlisted schools",
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildCenteredDeletePoint(
                      "Child profiles",
                      isDark,
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "This action cannot be undone",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _deleteAccount(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

// ✅ CENTERED BULLET POINT WIDGET
  Widget _buildCenteredDeletePoint(String text, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => const Center(
        child: Card(
          margin: EdgeInsets.all(40),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  "Deleting account...",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        throw Exception("User ID not found");
      }

      // 🔥 Call delete API
      final deleteService = DeleteAccountService();
      final result = await deleteService.deleteAccount(userId);

      if (result['success'] == true) {
        // ✅ Clear all local data (Hive, SharedPreferences, Secure Storage)
        await _clearAllData();

        if (!context.mounted) return;

        Navigator.pop(context); // Close loading dialog

        // 🚀 Navigate to Login (use pushAndRemoveUntil from navigatorKey)
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      } else {
        throw Exception(result['message'] ?? 'Failed to delete account');
      }
    } catch (e, stack) {
      // Log error to Crashlytics
      FirebaseCrashlytics.instance.recordError(e, stack);

      if (!context.mounted) return;

      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text("Failed to delete account: ${e.toString()}"),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

// ✅ Separate function to clear all data
  Future<void> _clearAllData() async {
    try {
      // 1. Clear Secure Storage
      await _secureStorage.deleteAll();

      // 2. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Clear Hive boxes (only clear, don't close)
      final schoolBox = Hive.box('schools');
      final masterBox = Hive.box('masterData');
      final shortlistBox = Hive.box('shortlist');

      await schoolBox.clear();
      await masterBox.clear();
      await shortlistBox.clear();

      // 4. Reset GlobalData
      GlobalData().reset();

      debugPrint('✅ All local data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
      // Don't throw - allow navigation to continue
    }
  }


}
