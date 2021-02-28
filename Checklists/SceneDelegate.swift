//
//  SceneDelegate.swift
//  Checklists
//
//  Created by Eduardo Martin Lorenzo on 01/02/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    // 1.Al crear la variable se llama al metodo que carga los datos del archivo .plis
    let dataModel = DataModel()

    // Metodo modificado
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let navigationController = window!.rootViewController as! UINavigationController
        let controller = navigationController.viewControllers[0] as! AllListsViewController
        //2. Esto le pasa al controller, en este caso a AllListsViewController el dataModel, es decir, todas las listas con sus elementos
        controller.dataModel = dataModel
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        saveData()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        saveData()
    }
    
    // MARK:- Helper Methods (Metodos propios)
    func saveData() {
        dataModel.saveChecklistItems()
    }


}

