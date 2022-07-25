import UIKit
import AVFoundation
import FBSDKCoreKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import NotificationBannerSwift
import UserNotifications
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var player: AVAudioPlayer?
    static var _settings: SettingsManager?
    
    static var settings: SettingsManagerProtocol?
    {
        if let _ = WSManager._settings {
        }
        else {
            WSManager._settings = SettingsManager()
        }

        return WSManager._settings
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        for family: String in UIFont.familyNames {
//            print("\(family)")
//            for names: String in UIFont.fontNames(forFamilyName: family) {
//                print("== \(names)")
//            }
//        }
        
        StoreKitHelper.incrementNumberOfTimesLaunched()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        registerForNotifications(application)
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        TWTRTwitter.sharedInstance().start(withConsumerKey: "ZJ3ut3uDF14UsEMxjtrNGsgrN", consumerSecret: "SR50wDlQ9hyj1BHI5qCGL7adHF4YbfOK3ymEv8fjpGSvXpydYx")
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func registerForNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let fbUrl = ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        let googleUrl = GIDSignIn.sharedInstance().handle(url)
        let twitterUrl = TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        
        if Auth.auth().canHandle(url) {
            return true
        }
        
        if fbUrl {
            return true
        }
        
        if googleUrl {
            return true
        }
        
        if twitterUrl {
            return true
        }
        
        return false
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func playSound() {
        guard let path = Bundle.main.path(forResource: "default_sound", ofType: "mpeg") else {
            return
        }
        
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: - NOTIFICATIONS DELEGATE
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "")")
        self.refreshToken(fcmToken ?? "")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            if let alert = aps["alert"] as? [String: AnyObject] {
                if let body = alert["body"] as? String {
                    if body.contains("sent you a friend request") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            homeViewControllerDelegate?.sendToFriendRequest()
                        })
                    }
                }
            }
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            if let alert = aps["alert"] as? [String: AnyObject] {
                let title = alert["title"] as? String
                let body = alert["body"] as? String
                
                let banner = NotificationBanner.init(title: title, subtitle: body, style: .success)
                banner.backgroundColor = WishieMeColors.greenColor
                banner.duration = 10.0
                banner.show()
                
                if (aps["sound"] as? String) != nil {
                    self.playSound()
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            friendRequestViewControllerDelegate?.refresh()
            homeViewControllerDelegate?.refreshData()
            labelsViewControllerDelegate?.refreshLabels()
            userProfileViewControllerDelegate?.refreshData()
            blockViewControllerDelegate?.refresh()
            notificationViewControllerDelegate?.refreshData()
        })
        
        completionHandler([])
    }
}

// MARK: - API CALL
extension AppDelegate {
    func refreshToken(_ token: String) {
        let params: [String: AnyObject] = [WSRequestParams.deviceToken: token as AnyObject]
        WSManager.wsCallRefreshToken(params) { (isSuccess, message) in
            
        }
    }
}
