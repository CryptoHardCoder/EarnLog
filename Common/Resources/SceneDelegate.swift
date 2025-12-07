//
//  SceneDelegate.swift
//  JobData
//
//  Created by M3 pro on 13/07/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)

        windowScene.traitOverrides.appTheme = ThemeManager.shared.userTheme
//        print("windowScene: \(windowScene.traitOverrides.appTheme.name)")

            // Создаем зависимости
        let viewModelFactory = ViewModelFactory(dependencies: .shared)
        let viewFactory = ViewControllersFactory(viewModelsFactory: viewModelFactory)

            // Создаем и запускаем главный координатор
        let coordinator = AppCoordinator(viewFactory: viewFactory, window: window!)
        self.appCoordinator = coordinator

        coordinator.start()
//        window?.rootViewController = TabBarController()
//        window?.makeKeyAndVisible()



//        print("🚀 Приложение запускается - проверяем необходимость CSV архивации")
//        AppCoreServices.shared.archiveManager.checkArchiveOnAppStart()
        
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
//        AppCoreServices.shared.archiveManager.checkArchiveOnAppStart()
    }

}

