//
//  SceneDelegate.swift
//  DicePro
//
//  Created by Dmitri on 30.11.25.
//

import UIKit

/// Handles scene lifecycle and sets up the initial window & root view controller.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // MARK: - Scene Lifecycle
    
    /// Called when the scene is first created. Sets up the window and root view controller.
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        // Create root view controller
        let rootVC = DiceViewController()
        let navigationController = UINavigationController(rootViewController: rootVC)
        
        // Create and attach window
        let window = UIWindow(windowScene: scene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when the scene is released by the system.
        // Clean up resources here if needed.
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the app becomes active.
        // Restart paused tasks or refresh UI if needed.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene moves from active to inactive state.
        // Pause ongoing tasks or disable timers.
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called when transitioning from background to foreground.
        // Undo background changes here.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called when transitioning to the background.
        // Save data and release shared resources here if needed.
    }
}
