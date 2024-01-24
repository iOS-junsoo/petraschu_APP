//
//  

//  FlareLaneNotificationServiceExtension
//
//  Created by 준수김 on 2024/01/23.
//

import UserNotifications
import FlareLane

class NotificationService: FlareLaneNotificationServiceExtension {
    
}

//MARK: - 다른 노티 서비스를 사용할 떄

//class NotificationService: UNNotificationServiceExtension {
//
//    var contentHandler: ((UNNotificationContent) -> Void)?
//    var bestAttemptContent: UNMutableNotificationContent?
//
//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        if FlareLaneNotificationServiceExtensionHelper.shared.isFlareLaneNotification(request) {
//          FlareLaneNotificationServiceExtensionHelper.shared.didReceive(request, withContentHandler: contentHandler)
//        } else {
//          // 플레어레인이 아닌 다른 알람 서비스인 경우 처리
//        }
//    }
//
//    override func serviceExtensionTimeWillExpire() {
//
//        FlareLaneNotificationServiceExtensionHelper.shared.serviceExtensionTimeWillExpire()
//    }
//
//}



//MARK: - 원본

//import UserNotifications
//
//class NotificationService: UNNotificationServiceExtension {
//
//    var contentHandler: ((UNNotificationContent) -> Void)?
//    var bestAttemptContent: UNMutableNotificationContent?
//
//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//
//        if let bestAttemptContent = bestAttemptContent {
//            // Modify the notification content here...
//            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
//
//            contentHandler(bestAttemptContent)
//        }
//    }
//
//    override func serviceExtensionTimeWillExpire() {
//        // Called just before the extension will be terminated by the system.
//        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
//        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
//            contentHandler(bestAttemptContent)
//        }
//    }
//
//}
