//
//  AppDelegate.swift
//  SmartCycle
//
//  Created by Joao Duarte on 22/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import UIKit
import UserNotifications
import AirshipKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        resetStateIfUITesting()
        setUpGoogleAnalytics()
        setUpUrbanAirship()
        registerForPushNotifications()

        let storyboard = UIStoryboard(name: Constants.Storyboard.MainStoryboard, bundle: nil)

        if let navController = window?.rootViewController as? UINavigationController, let loginViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.ViewController.LoginViewController) as? LoginViewController, let _ = UserManager.sharedInstance.user {
            UIView.setAnimationsEnabled(false)
            navController.pushViewController(loginViewController, animated: false)
            loginViewController.performSegue(withIdentifier: Constants.Storyboard.Segue.HomeSegue, sender: nil)
            UIView.setAnimationsEnabled(true)
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }

        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        let aps = userInfo["aps"] as! [String: AnyObject]
        print("Notification content: \(aps)")
    }

    fileprivate func setUpGoogleAnalytics() {
        if let gai = GAI.sharedInstance() {
            gai.tracker(withTrackingId: Constants.Keys.GoogleAnalyticsKey)
            gai.trackUncaughtExceptions = true
            gai.logger.logLevel = .error
        }
    }

    fileprivate func setUpUrbanAirship() {
         let config = UAConfig.default()
        UAirship.takeOff(config)
        UAirship.push()?.resetBadge()
    }

    private func resetStateIfUITesting() {
        if ProcessInfo.processInfo.arguments.contains("UI-Testing") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
    }

    // MARK: Push Notifications
    fileprivate func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")

            guard granted else { return }
            UNUserNotificationCenter.current().delegate = self 
            self.getNotificationSettings()
        }
    }

    fileprivate func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            })
        }
    }
}

// This is necessary for showing push notifications if the app is already running
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

