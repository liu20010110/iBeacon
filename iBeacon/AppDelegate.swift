//
//  AppDelegate.swift
//  iBeacon
//
//  Created by 劉陶恩 on 2023/3/6.
//

import UIKit
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in
              if granted {
              } else {
                 print("使用者不同意，不喜歡米花兒，哭哭!")
              }
           })
        locationManager.delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            guard region is CLBeaconRegion else { return }

            let content = UNMutableNotificationContent()
            content.title = "iBeacon Demo"
            content.body = "You enter a region"
            content.sound = .default

            let request = UNNotificationRequest(identifier: "Demo", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }

        func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
            guard region is CLBeaconRegion else { return }

            let content = UNMutableNotificationContent()
            content.title = "iBeacon Demo"
            content.body = "You exit a region"
            content.sound = .default

            let request = UNNotificationRequest(identifier: "Demo", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
}

