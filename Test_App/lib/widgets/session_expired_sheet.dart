import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:school_scout/screens/login/enter_pin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global/global_data.dart';
import 'package:school_scout/screens/login/login_page.dart';

import '../main.dart';

class SessionExpiredSheet {
  static bool _isShowing = false;

  static void show() {
    if (_isShowing) return;
    _isShowing = true;

    final context = navigatorKey.currentContext;
    if (context == null) {
      _isShowing = false;   // 🔥 reset
      return;
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline,
                  size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text(
                'Session Expired',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your session has expired. Please sign in again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    _isShowing = false;
                    const storage = FlutterSecureStorage();
                    final prefs = await SharedPreferences.getInstance();
                    await storage.delete(key: 'accessToken');
                    await storage.delete(key: 'refreshToken');  // remove auth
                    await prefs.setBool('isLoggedIn', false);

                    String mobileNumber = GlobalData().mobNumber.toString();

                    // navigatorKey.currentState?.pushAndRemoveUntil(
                    //   MaterialPageRoute(
                    //     builder: (_) => EnterPinScreen(mobileNumber: mobileNumber),
                    //   ),
                    //       (_) => false,
                    // );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => EnterPinScreen(mobileNumber: mobileNumber)),
                          (route) => false, // 🔥 PURA STACK CLEAR
                    );
                  },
                  child: const Text('Sign in again'),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      _isShowing = false;   // 🔥 always reset
    });
  }
}
