//
//  AccountSettingsCoordinator.swift
//  EarnLog
//
//  Created by M3 pro on 05/11/2025.
//
import UIKit
import OSLog

final class AccountSettingsCoordinator: Coordinator {

        //MARK: - Properties

    var childCoordinators: [any Coordinator] = []

    var viewFactory: any ViewControllersFactoryProtocol

    private let navigationController: UINavigationController

    var onFinished: (() -> ())?

        //MARK: - Initialization / Deinitialization

    init(viewFactory: any ViewControllersFactoryProtocol, navController: UINavigationController) {
        self.viewFactory = viewFactory
        self.navigationController = navController
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: DSColors.appTextPrimary]

        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "AccountSettingsCoordinator inited")
        Logger.coordinator.debug("\(logMessage, align: .right(columns: 50), privacy: .public)")
    }

    deinit {
        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "AccountSettingsCoordinator deinited")
        Logger.coordinator.debug("\(logMessage, align: .right(columns: 50), privacy: .public)")
    }

        //MARK: - Coordinator Start

    func start() {
        let vc = viewFactory.makeAccountSettingsViewController()
        vc.navigationItem.backButtonDisplayMode = .minimal
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }

        //MARK: - Manage flows

    private func showChangePassword() {
        let vc = viewFactory.makeChangePasswordViewController()
        vc.navigationItem.backButtonDisplayMode = .minimal
//
//        vc.onFinished = { [weak self] in
//            self?.navigationController.popViewController(animated: true)
//
//        }
        navigationController.pushViewController(vc, animated: true)

    }

    private func showEditEmail(){
        let vc = viewFactory.makeChangeEmailViewController()
        vc.navigationItem.backButtonDisplayMode = .minimal
        vc.onEmailSended = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
//        if let sheet = vc.sheetPresentationController {
//            sheet.detents = [.custom(resolver: { context in
//                CGFloat(integerLiteral: 300)
//            })]
//            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//            sheet.prefersEdgeAttachedInCompactHeight = true
//            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
//            sheet.prefersGrabberVisible = true
//            sheet.preferredCornerRadius = 20
//        }
//        navigationController.present(vc, animated: true)
        navigationController.pushViewController(vc, animated: true)
    }

}

    //MARK: -AccountSettingsViewControllerDelegate

extension AccountSettingsCoordinator: AccountSettingsViewControllerDelegate {

    func accountSettingViewController(_ controller: AccountSettingsViewController,
                                      didSelect destination: SettingsDestination) {

        switch destination {
            case .account(let array):
                guard !array.isEmpty else {
                    return
                }

                if array[0] == .updateEmail {
                    showEditEmail()
                } else if array[0] == .updatePassword {
                    showChangePassword()
                }

            default: break
        }
    }

    func accountSettingsViewControllerDidFinish(_ controller: AccountSettingsViewController) {
        onFinished?()
    }
}

extension AccountSettingsCoordinator: ChangePasswordViewControllerDelegate{

    func changePasswordViewControllerDidFinish(_ changePasswordViewController: UIViewController) {
        navigationController.popViewController(animated: true)
    }

    func changePasswordViewControllerForgotPassword(_ changePasswordViewController: UIViewController) {
//        navigationController.pushViewController(<#T##viewController: UIViewController##UIViewController#>, animated: <#T##Bool#>)
    }


}
