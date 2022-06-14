//
//  AppDelegate.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 15.05.2022.
//

import UIKit
import Firebase
import Appirater

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Appirater.appLaunched(true)
        Appirater.setDebug(false)
        Appirater.setAppId("1234781")
        Appirater.setDaysUntilPrompt(7)
        FirebaseApp.configure()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        window.rootViewController = HomeViewController()
        window.makeKeyAndVisible()
        self.window = window
        
        //Add  dummy notification for current user
//        let id = NotificationsManager.newIdentifier()
//        let model = IGNotification(
//            identifier: id,
//            notificationType: 1,
//            profilePictureUrl: "https://images.pexels.com/photos/874158/pexels-photo-874158.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
//            username: "elonmusk",
//            dateString: String.date(with: Date()),
//            isFollowing: nil,
//            postId: "1234",
//            postUrl: "https://images.pexels.com/photos/347141/pexels-photo-347141.jpeg")
//        NotificationsManager.shared.create(notification: model, for: "test")
        
        return true
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Appirater.appEnteredForeground(true)
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

