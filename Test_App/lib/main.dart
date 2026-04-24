import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/spash/splash_screen.dart';
import 'themes/theme_provider.dart';
import 'themes/light_mode.dart';
import 'config/env.dart';

import 'hive/models/address_hive.dart';
import 'hive/models/city_hive.dart';
import 'hive/models/feature_facility_hive.dart';
import 'hive/models/feature_hive.dart';
import 'hive/models/user_hive.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;


// 🔴 Background handler (TOP LEVEL only)
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔴 BG Push: ${message.notification?.title}");
}

void main() async {
  // Catch any errors during initialization
  runZonedGuarded(() async {
    Env.current = EnvType.production;
    WidgetsFlutterBinding.ensureInitialized();



    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      print("✅ Firebase initialized");


      // 🔥 Catch Flutter errors
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // 🔥 Catch async errors
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };


      // Setup background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);


      print("✅ Background message handler registered");
    } catch (e) {
      print("❌ Firebase initialization error: $e");
    }

    try {
      // Initialize Mobile Ads
      await MobileAds.instance.initialize();
      print("✅ Mobile Ads initialized");
    } catch (e) {
      print("❌ Mobile Ads initialization error: $e");
    }

    try {
      // Initialize Hive
      await Hive.initFlutter();

      Hive.registerAdapter(UserHiveAdapter());
      Hive.registerAdapter(AddressHiveAdapter());
      Hive.registerAdapter(CityHiveAdapter());
      Hive.registerAdapter(FeatureFacilityHiveAdapter());
      Hive.registerAdapter(FeatureHiveAdapter());

      await Hive.openBox<UserHive>('schools');
      await Hive.openBox('masterData');
      await Hive.openBox('shortlist');
      print("✅ Hive initialized");
    } catch (e) {
      print("❌ Hive initialization error: $e");
    }

    // Run the app immediately
    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

    // Note: Push service, ATT, and app updates are now handled in SplashScreen
    // This gives better control over timing and prevents duplicate initialization

  }, (error, stack) {
    print("❌ Unhandled error in main: $error");
    print("Stack trace: $stack");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      navigatorKey: navigatorKey,
      theme: lightMode,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}