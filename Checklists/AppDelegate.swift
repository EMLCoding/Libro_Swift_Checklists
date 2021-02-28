//
//  AppDelegate.swift
//  Checklists
//
//  Created by Eduardo Martin Lorenzo on 01/02/2021.
//

import UIKit
// Para que puedan aparecer notificaciones locales
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {


    // Esta funcion se llama automaticamente cuando se inicia la app
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Autorizacion de notificaciones :Esta notificacion local solo se mostrara si la app esta en segundo plano
        let center = UNUserNotificationCenter.current()
                
        // Esto sirve para que se ejecute el metodo del UNUserNotificationCenterDelegate y se pueda hacer algo cuando salte la notificacion (que no va a ser visible) y la app este en primer plano
        center.delegate = self
    
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
    
    // MARK:- User Notification Delegates
    // Esta funcion se llamara si la app esta en primer plano y se ejecuta la funcion que crea la notificacion local
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received local notification \(notification)")
    }


}

