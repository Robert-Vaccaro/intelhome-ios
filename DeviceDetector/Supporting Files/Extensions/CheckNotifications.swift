//
//  CheckNotifications.swift
//  DeviceDetector
//
//  Created by Bobby on 11/22/24.
//

import UIKit
import UserNotifications
extension BaseVC{
    func checkNotificationSettingsAndRegister(completion: @escaping (UNAuthorizationStatus) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    func registerForPushNotifications(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    completion(true) // Notifications allowed
                }
            } else {
                DispatchQueue.main.async {
                    completion(false) // Notifications denied
                }
            }
        }
    }

}
