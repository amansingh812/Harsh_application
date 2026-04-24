import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_scout/screens/login/enter_pin_screen.dart';
import 'package:school_scout/screens/login/login_page.dart';


import '../../global/global_data.dart';
import 'home_loader_screen.dart';

class AppLaunchPage extends StatefulWidget {
  const AppLaunchPage({super.key});

  @override
  State<AppLaunchPage> createState() => _AppLaunchPageState();
}

class _AppLaunchPageState extends State<AppLaunchPage> {
  @override
  void initState() {
    super.initState();
    _decideNext();
  }

  Future<void> _decideNext() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final isGuestUser = prefs.getBool('isGuestUser') ?? false;

    final phone = prefs.getString('phoneNumber');

    // Load city & pincode
    GlobalData().city = prefs.getString('city') ?? 'Bangalore';
    GlobalData().pincode = prefs.getString('pincode') ?? '560001';

    await Future.delayed(const Duration(milliseconds: 500)); // splash feel

    if (!mounted) return;

    if (isLoggedIn && phone != null) {
      // ✅ Already logged in → go to PIN
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_)  => EnterPinScreen(mobileNumber: phone)),
      );
    } else if (isGuestUser) {
      // 👤 Guest user → Direct to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeLoaderScreen(),
        ),
      );
    }

    else {


      // ❌ New / logged-out user
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
