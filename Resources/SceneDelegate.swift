//
//  SceneDelegate.swift
//  JobData
//
//  Created by M3 pro on 13/07/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = TabBarController()
//        window?.rootViewController = AddRecordViewController()
        window?.makeKeyAndVisible()
        
//        print("🚀 Приложение запускается - проверяем необходимость CSV архивации")
        ArchiveManager.shared.checkArchiveOnAppStart()
        
    }

//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        // ... ваш существующий код настройки UI ...
//        
//        print("🚀 Приложение запускается - проверяем необходимость CSV архивации")
//        AppFileManager.shared.checkArchiveOnAppStart()
//        
//        // ... остальной код ...
//    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
//        print("📱 Приложение стало активным - проверяем дату для CSV архивации")
        ArchiveManager.shared.checkArchiveOnAppStart()
    }

}

