//
//  AppDelegate.swift
//  ROKOKeyboard
//
//  Created by Maslov Sergey on 06.06.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import UIKit
import ROKOMobi
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    lazy var pushComponent = ROKOPush()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Register for Apple Remote Push Notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }                    
                }
            }
        } else {
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()
        }
            
        // Handle the case when application has opened from click on notification
        if let remoteNotificationInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [NSObject : AnyObject]{
            self.application(application, didReceiveRemoteNotification: remoteNotificationInfo)
        }
		
		return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushComponent.register(withAPNToken: deviceToken as Data!) { (responseObject, error) in
            if let error = error {
                print("Failed to register with error: \(error.localizedDescription)")
            }            
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Notification arrived. Payload: \(userInfo)")
        pushComponent.handleNotification(userInfo)
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        pushComponent.handleNotification(userInfo)
    }
}
