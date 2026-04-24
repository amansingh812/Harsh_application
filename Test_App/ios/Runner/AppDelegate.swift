import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import google_mobile_ads
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Configure Firebase FIRST
    FirebaseApp.configure()

    // Register plugins
    GeneratedPluginRegistrant.register(with: self)

    // Google Mobile Ads
    let factory = ListTileNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self, factoryId: "schoolCard", nativeAdFactory: factory)
    GADMobileAds.sharedInstance().start(completionHandler: nil)

    // Google Maps
    GMSServices.provideAPIKey("AIzaSyDNYm-0_zjDSzsnkpcnYgF8eGbmcEexwI8")

    // Setup Push Notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self

      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { granted, error in
            print("✅ Notification permission granted: \(granted)")
            if let error = error {
              print("❌ Notification permission error: \(error.localizedDescription)")
            }
          }
      )
    } else {
      let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    // Register for remote notifications
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Called when APNS successfully registers the device
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("✅ APNS device token received")

    // Pass the device token to Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken

    // Also call super to ensure Flutter plugins get the token
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // Called when APNS registration fails
  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
  }

  // Handle notification when app is in foreground (iOS 10+)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    print("📬 Received notification in foreground: \(userInfo)")

    // Show notification even when app is in foreground
    if #available(iOS 14.0, *) {
      completionHandler([[.banner, .badge, .sound]])
    } else {
      completionHandler([[.alert, .badge, .sound]])
    }
  }

  // Handle notification tap
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    print("👆 User tapped notification: \(userInfo)")

    completionHandler()
  }
}