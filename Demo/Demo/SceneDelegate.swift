//
//  SceneDelegate.swift
//  Demo
//

import UIKit

public class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK: Properties

    public var window: UIWindow? = nil

    // MARK: Functions

    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard (scene as? UIWindowScene) != nil else {
            return
        }
    }

    public func sceneDidDisconnect(_ scene: UIScene) {}

    public func sceneDidBecomeActive(_ scene: UIScene) {}

    public func sceneWillResignActive(_ scene: UIScene) {}

    public func sceneWillEnterForeground(_ scene: UIScene) {}

    public func sceneDidEnterBackground(_ scene: UIScene) {}
}
