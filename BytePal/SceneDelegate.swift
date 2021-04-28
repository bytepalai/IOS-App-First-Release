//
//  SceneDelegate.swift
//  BytePal
//
//  Created by Scott Hom on 7/10/20.
//  Copyright © 2020 BytePal. All rights reserved.
//

import UIKit
import SwiftUI
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        

        
        
        // Init view
        setKeyWindow(scene)
        
    }

    func setKeyWindow(_ scene: UIScene) {
        // Get the managed object context from the shared persistent container.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // EnvironmentObjects (stored in RAM)
        //// Messages
        let messages = Messages()
        //// Device model (example: iPhon 12, iPhone 12 Pro Max, etc ... )
        let deviceInfo = DeviceInfo()
        //// User information
        let userInformation = UserInformation()
        
        // Observable Object
        //// Google sign in. Declared so user ID, email, etc ... can be returend from class model to the UI to store in EnvironmentObject UserInformation.
        let googleDelegate = (UIApplication.shared.delegate as! AppDelegate).googleDelegate
        
        let contentView = ContentView().environment(\.managedObjectContext, context).environmentObject(messages).environmentObject(userInformation).environmentObject(googleDelegate).environmentObject(deviceInfo)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.overrideUserInterfaceStyle = .light
            window.rootViewController = UIHostingController(rootView: contentView)
            
            // Set presentingViewControll to rootViewController
            GIDSignIn.sharedInstance().presentingViewController = window.rootViewController
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
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
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

