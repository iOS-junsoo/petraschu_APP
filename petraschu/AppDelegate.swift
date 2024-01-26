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
        FlareLane.initWithLaunchOptions(launchOptions, projectId: "1f13badc-fe56-429d-8961-d491d6316085", requestPermissionOnLaunch: false)
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
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    FlareLaneNotificationCenter.shared.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
  }
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
      print("알람 클릭됨")
      
    FlareLaneNotificationCenter.shared.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
      
  }
    
 func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        print("알람 수신됨")
     // 비동기 작업을 수행하고 결과를 반환할 때에는 await 키워드를 사용
             let result = await performAsyncTask()
             
             // 비동기 작업의 결과에 따라서 적절한 UIBackgroundFetchResult를 반환
             switch result {
             case .success:
                 return .newData
             case .failure:
                 return .failed
             }
    }
    
    func performAsyncTask() async -> Result<Void, Error> {
            // 비동기 작업을 여기에 구현
            return .success(())
        }
    
}

