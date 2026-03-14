import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import GoogleMaps
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCiQkUJ_S5g0KYS8efMk0MBi5f_CO9Y27Y")
    // Configure Firebase
    if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
      FirebaseApp.configure()
      print("✅ Firebase configured successfully")
    } else {
      print("❌ GoogleService-Info.plist not found")
    }

    // Set up messaging delegate
    Messaging.messaging().delegate = self

    // Request notification permissions
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { granted, error in
          if granted {
            print("✅ Notification permission granted")
          } else {
            print("❌ Notification permission denied: \(String(describing: error))")
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

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle successful APNs registration
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("✅ APNs token received")
    Messaging.messaging().apnsToken = deviceToken
  }

  // Handle APNs registration failure
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ Failed to register for remote notifications: \(error)")
  }

  // Handle foreground notifications (iOS 10+)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo

    print("📱 Foreground notification received:")
    print("Title: \(notification.request.content.title)")
    print("Body: \(notification.request.content.body)")
    print("UserInfo: \(userInfo)")

    // Show notification even when app is in foreground
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  // Handle notification taps
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo

    print("👆 Notification tapped:")
    print("Title: \(response.notification.request.content.title)")
    print("Body: \(response.notification.request.content.body)")
    print("UserInfo: \(userInfo)")

    // Handle navigation based on notification data
    if let screen = userInfo["screen"] as? String {
      // You can pass this to Flutter using MethodChannel
      print("🚀 Navigate to screen: \(screen)")
    }

    completionHandler()
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {

  // Handle FCM token updates
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔥 Firebase registration token: \(String(describing: fcmToken))")

    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )

    // TODO: Send token to your server here
    // sendTokenToServer(fcmToken)
  }

  // Handle APNs token updates
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?, completion: @escaping (Error?) -> Void) {
    print("🔄 Firebase registration token updated: \(String(describing: fcmToken))")

    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )

    completion(nil)
  }
}
