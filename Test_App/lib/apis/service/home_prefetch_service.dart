import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:school_scout/apis/service/short_list_sync_service.dart';
import 'package:school_scout/hive/mappers/user_hive_to_user.dart';
import 'package:school_scout/hive/mappers/user_to_hive_mapper.dart';

import '../../global/global_data.dart';
import '../../hive/models/user_hive.dart';
import '../api_service.dart';

class HomePrefetchService {
  static bool _started = false;
  static bool _fcmInit = false;

  static Future<void> preload() async {
    if (_started) return;
    _started = true;

    _initFCM();
    _setDefaultCity();

    final box = Hive.box<UserHive>('schools');

    // 1️⃣ FIRST: load from Hive (FAST)
    if (box.isNotEmpty) {
      print('✅ Users loaded from Hive');

      final loadedUsers = box.values
          .map((hiveUser) => hiveUser.toUser())
          .toList();
      GlobalData().users = loadedUsers;
      GlobalData().buildThumbnailCache(loadedUsers);

      GlobalData.homeDataReady.value = true;

      // 🔄 Background sync (non-blocking)
      _runBackgroundTasks();
      return;
    }

    // 2️⃣ Hive empty → API call
    print('🌐 Hive empty → fetching users from API');

    try {
      final apiService = ApiService();
      final users = await apiService.fetchUser(GlobalData().pincode);

      GlobalData().users = users;
      GlobalData.homeDataReady.value = true;

      // 3️⃣ Save to Hive (background)
      unawaited(_saveUsersToHive(users));

      // 4️⃣ Shortlist sync (background)
      _runBackgroundTasks();
    } catch (e) {
      print('❌ Home prefetch failed: $e');
      GlobalData.homeDataReady.value = true;
    }
  }

  // ---------------- helpers ----------------

  static void _setDefaultCity() {
    if (GlobalData().city.isEmpty) {
      GlobalData().city = 'Bangalore';
      GlobalData().pincode = '560066';
    }
  }

  static void _initFCM() {
    if (_fcmInit) return;
    _fcmInit = true;

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🟢 Notification clicked');
    });
  }

  static void _runBackgroundTasks() {
    final mobNumber = GlobalData().mobNumber.toString();

    // fire & forget
    unawaited(
      ShortListSyncService.syncIfEmpty(mobNumber),
    );
  }

  static Future<void> _saveUsersToHive(List users) async {
    final box = Hive.box<UserHive>('schools');

    final Map<String, UserHive> map = {};
    for (final u in users) {
      map[u.id.toString()] = u.toHive();
    }

    await box.putAll(map);
  }
}
