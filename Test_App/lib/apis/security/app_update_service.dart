import 'dart:io'; // Add this import
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateService {
  static Future<void> checkAndUpdate() async {
    // Only run on Android - iOS uses App Store for updates
    if (!Platform.isAndroid) {
      debugPrint('ℹ️ In-app updates only available on Android');
      return;
    }

    try {
      debugPrint('🔍 Checking for app updates...');

      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        debugPrint('✅ Update available');

        if (info.immediateUpdateAllowed) {
          // 🔥 FORCE UPDATE (for critical updates)
          debugPrint('🔥 Starting immediate update...');
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          // 🟡 FLEXIBLE UPDATE (user can continue using app)
          debugPrint('🟡 Starting flexible update...');
          await InAppUpdate.startFlexibleUpdate();

          // Listen for download completion
          InAppUpdate.completeFlexibleUpdate().then((_) {
            debugPrint('✅ Flexible update completed');
          });
        }
      } else {
        debugPrint('ℹ️ No update available');
      }
    } catch (e) {
      // Silently ignore - don't crash the app
      debugPrint('❌ In-app update error: $e');
    }
  }
}