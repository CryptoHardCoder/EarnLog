//
//  AppCoordinator.swift
//  EarnLog
//
//  Created by M3 pro on 03/11/2025.
//

import Foundation
import UIKit
import OSLog

final class AppCoordinator: Coordinator {

        //MARK: - Properties

    var childCoordinators: [any Coordinator] = []
    
    var viewFactory: any ViewControllersFactoryProtocol

    let navigationController: UINavigationController = {
        let nav = UINavigationController()
        nav.configureNavigationBar()
        return nav
    }()

    private let window: UIWindow

        //MARK: - Initialization / Deinitialization

    init(viewFactory: any ViewControllersFactoryProtocol, window: UIWindow) {
        self.viewFactory = viewFactory
        self.window = window

        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "AppCoordinator inited")
        Logger.coordinator.debug("\(logMessage, align: .left(columns: 10), privacy: .public)")
    }

    deinit {
        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "AppCoordinator deinited")
        Logger.coordinator.debug("\(logMessage, align: .left(columns: 10), privacy: .public)")
    }

        //MARK: - Coordinator Start

    func start() {
        if shouldShowOnboarding() {
            showOnboardingFlow()
        } else if shouldShowLogin() {
            showLoginFlow()
        } else {
            showMainFlow()
        }

    }
        //MARK: - Manage flows
    private func shouldShowOnboarding() -> Bool{
        //TODO: - Проверка, на первый запуск приложения
        return !true

    }

    private func shouldShowLogin() -> Bool{
        //TODO: - Проверка, залогинен ли пользователь
        return !true

    }

    private func showOnboardingFlow(){
        let coordinator = OnboardingCoordinator(viewFactory: viewFactory,
                                                navigationController: navigationController)
        coordinator.onFinish = { [weak self] in
            self?.removeChild(coordinator)
            self?.showLoginFlow()
        }
        addChild(coordinator)
        coordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    private func showLoginFlow(){
        let coordinator = LoginCoordinator(viewFactory: viewFactory,
                                           navigationController: navigationController)
        coordinator.onLoginSuccess = { [weak self] in
            self?.removeChild(coordinator)
            self?.showMainFlow()
        }

        addChild(coordinator)
        coordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    private func showMainFlow(){
        let tabBar = UITabBarController()
        let coordinator = MainCoordinator(tabBarController: tabBar, viewFactory: viewFactory)
        coordinator.onLogOut = { [weak self] in
            self?.removeChild(coordinator)
            self?.showLoginFlow()
        }

        addChild(coordinator)
        coordinator.start()

        window.rootViewController = coordinator.tabBarController
        window.makeKeyAndVisible()
    }


}
