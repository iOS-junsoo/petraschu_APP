//
//  AppDelegate.swift
//  petraschu_APP
//
//  Created by 준수김 on 2023/12/15.
//

import UIKit
import FlareLane


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        // 알림 권한 팝업 타이밍을 제어하려면 세 번째 파라미터를 false로 설정 후 적절한 시점에 .subscribe() 함수 실행
        FlareLane.initWithLaunchOptions(launchOptions, projectId: "fdb558a8-6323-495f-aee3-2d8b542a97eb", requestPermissionOnLaunch: true)
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FlareLaneAppDelegate.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
      }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
  // 2
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    FlareLaneNotificationCenter.shared.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
  }
  // 3
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    FlareLaneNotificationCenter.shared.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
}
