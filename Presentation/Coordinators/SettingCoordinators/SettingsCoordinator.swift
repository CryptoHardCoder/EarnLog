//
//  SettingsCoordinator.swift
//  EarnLog
//
//  Created by M3 pro on 03/11/2025.
//

import Foundation
import UIKit
import OSLog

final class SettingsCoordinator: Coordinator {

        //MARK: - Properties

    var childCoordinators: [any Coordinator] = []

    let navigationController: UINavigationController

    var viewFactory: any ViewControllersFactoryProtocol

    var onLogOut: (() -> Void)?

        //MARK: - Initialization / Deinitialization

    init(navigationController: UINavigationController, viewFactory: ViewControllersFactoryProtocol) {
        self.navigationController = navigationController
        self.viewFactory = viewFactory

        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "SettingsCoordinator inited")
        Logger.coordinator.debug("\(logMessage, align: .right(columns: 50), privacy: .public)")
    }

    deinit {
        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "SettingsCoordinator deinited")
        Logger.coordinator.debug("\(logMessage, align: .right(columns: 50), privacy: .public)")
    }

        //MARK: - Coordinator Start

    func start() {
        showMainSettings()
    }

        //MARK: - Manage flows

    private func showMainSettings(){
        let settingsVC = viewFactory.makeSettingsViewController()
        settingsVC.navigationItem.backButtonDisplayMode = .minimal
        settingsVC.delegate = self

        navigationController.pushViewController(settingsVC, animated: true)
    }

    private func navigate(to destination: SettingsDestination){
        switch destination {
            case .avatar:
                break
            case .account:
                showAccountSettings()
            case .security:
                showSecuritySettings()
            case .currency:
                showCurrencySettings()
            case .goals:
                showGoalSettings()
            case .sources:
                showSourcesSettings()
            case .appearance:
                showAppearanceSettings()
            case .notifications:
                showNotificationSettings()
            case .help:
                showHelp()
            case .rateApp:
                showRateApp()
            case .logOut:
                showLogOut()

        }
    }

    private func showAccountSettings() {
        let accountCoordinator = AccountSettingsCoordinator(viewFactory: viewFactory, navController: navigationController)

        accountCoordinator.onFinished = { [weak self, weak accountCoordinator] in
            guard let self,
                  let accountCoordinator else { return }
            removeChild(accountCoordinator)
        }

        childCoordinators.append(accountCoordinator)
        accountCoordinator.start()
    }


    private func showSecuritySettings(){
        print("showSecuritySettings")
    }

    private func showCurrencySettings(){
        print("showCurrencySettings")
    }

    private func showGoalSettings(){
        print("showGoalSettings")
    }

    private func showSourcesSettings(){
        print("showSourcesSettings")
    }

    private func showAppearanceSettings(){
//        print("showAppearanceSettings")
        let vc = viewFactory.makeChangeAppearanceViewController()

        navigationController.pushViewController(vc, animated: true)

    }

    private func showNotificationSettings(){
        print("showNotificationSettings")
    }

    private func showHelp(){
        print("showHelp")
    }

    private func showRateApp(){
        print("showRateApp")
    }

    private func showLogOut(){
        print("showLogOut")
    }

//    private func removeChild(_ coordinator: any Coordinator) {
//        childCoordinators.removeAll { $0 === coordinator as AnyObject }
//
//        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "Child removed. Child coordinators total: \(childCoordinators.count)")
//        Logger.coordinator.debug("\(logMessage, align: .right(columns: 50), privacy: .public)")
//    }

}
    //MARK: - Delegates

extension SettingsCoordinator: SettingsViewControllerDelegate {
    func settingsViewController(_ controller: SettingsViewController, didSelect destination: SettingsDestination) {
        navigate(to: destination)
    }
}
