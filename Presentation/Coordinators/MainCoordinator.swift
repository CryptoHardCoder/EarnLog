    //
    //  MainCoordinator.swift
    //  EarnLog
    //
    //  Created by M3 pro on 03/11/2025.
    //
import Foundation
import UIKit
import OSLog

final class MainCoordinator: NSObject, Coordinator {

        //MARK: - Properties

    var childCoordinators: [any Coordinator] = []
    var viewFactory: any ViewControllersFactoryProtocol
    var onLogOut: (() -> Void)?

    let tabBarController: UITabBarController

    private var customTabBar: MiddleTabBarButton?
    private var navigationControllers: [UINavigationController] = []

    private enum TabIndex: Int {
        case main = 0
        case statistics = 1
        case addIncome = 2
        case history = 3
        case settings = 4
    }

        //MARK: - Initialization / Deinitialization

    init(tabBarController: UITabBarController, viewFactory: any ViewControllersFactoryProtocol) {
        self.tabBarController = tabBarController
        self.viewFactory = viewFactory

        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "MainCoordinator inited")
        Logger.coordinator.debug("\(logMessage, align: .right(columns: 50), privacy: .public)")
    }

    deinit {
        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "MainCoordinator deinited")
        Logger.coordinator.debug("\(logMessage, align: .right(columns: 50), privacy: .public)")
    }

        //MARK: - Coordinator Start

    func start() {
        setupViewControllers()
        setupTabBarAppearance()
        configureNavigationBars()
    }

        //MARK: - Private methods

    private func setupViewControllers() {
        let mainNC = makeMainNavigationController()
        let statisticsNC = makeStatisticsNavigationController()
        let addIncomeNC = makeAddIncomeNavigationController()
        let historyNC = makeHistoryNavigationController()
        let settingsNC = makeSettingsNavigationController()

        navigationControllers = [mainNC, statisticsNC, addIncomeNC, historyNC, settingsNC]

        tabBarController.viewControllers = navigationControllers
        tabBarController.selectedIndex = TabIndex.main.rawValue
        tabBarController.delegate = self

        if #available(iOS 18.0, *) {
            tabBarController.selectedTab = mainNC.tab
        }
    }

    private func makeMainNavigationController() -> UINavigationController {
        let mainViewController = viewFactory.makeMainViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController)

        navigationController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "Home_icon_svg"),
            selectedImage: UIImage(named: "Home_icon_svg")
        )

        return navigationController
    }

    private func makeStatisticsNavigationController() -> UINavigationController {
        let statisticsViewController = StatsViewController()
        let navigationController = UINavigationController(rootViewController: statisticsViewController)

        navigationController.tabBarItem = UITabBarItem(
            title: "Stats",
            image: UIImage(named: "Stats_Icon_svg"),
            selectedImage: UIImage(named: "Stats_Icon_svg")
        )

        return navigationController
    }

    private func makeAddIncomeNavigationController() -> UINavigationController {
        let addIncomeViewController = viewFactory.makeAddIncomeViewController()
        let navigationController = UINavigationController(rootViewController: addIncomeViewController)

        if #available(iOS 26, *) {
            configureAddIncomeForModernIOS(navigationController)
        } else {
            configureAddIncomeForLegacyIOS(addIncomeViewController, navigationController)
        }

        return navigationController
    }

    private func makeHistoryNavigationController() -> UINavigationController {
        let historyViewController = HistoryViewController()
        let navigationController = UINavigationController(rootViewController: historyViewController)
        
        navigationController.tabBarItem = UITabBarItem(
            title: "History",
            image: UIImage(named: "History_icon_svg"),
            selectedImage: UIImage(named: "History_icon_svg")
        )
        
        return navigationController
    }

    private func makeSettingsNavigationController() -> UINavigationController {
        let settingsCoordinator = makeSettingsCoordinator()
        settingsCoordinator.onLogOut = onLogOut
        childCoordinators.append(settingsCoordinator)
        settingsCoordinator.start()

        return settingsCoordinator.navigationController
    }

    private func makeSettingsCoordinator() -> SettingsCoordinator {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(named: "settings_tab_Icon_svg"),
            selectedImage: UIImage(named: "settings_tab_Icon_svg")
        )

        return SettingsCoordinator(
            navigationController: navigationController,
            viewFactory: viewFactory
        )
    }

    private func configureAddIncomeForModernIOS(_ navigationController: UINavigationController) {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        navigationController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "plus.capsule.fill", withConfiguration: config),
            selectedImage: UIImage(systemName: "plus.capsule.fill", withConfiguration: config)
        )
        navigationController.tabBarItem.isEnabled = true
    }

    private func configureAddIncomeForLegacyIOS(
        _ viewController: UIViewController,
        _ navigationController: UINavigationController
    ) {
        navigationController.tabBarItem = UITabBarItem(title: "", image: nil, selectedImage: nil)
        navigationController.tabBarItem.isEnabled = false

        let customBar = MiddleTabBarButton(rootViewControllerForButton: viewController)
        self.customTabBar = customBar
        tabBarController.setValue(customBar, forKey: "tabBar")
    }

    private func configureNavigationBars() {
        navigationControllers.forEach { $0.configureNavigationBar() }
    }

    private func setupTabBarAppearance() {
        tabBarController.tabBar.tintColor = DSColors.appPrimary
        if #available(iOS 26, *) {
            tabBarController.tabBar.backgroundColor = .clear
        } else {
            tabBarController.tabBar.backgroundColor = DSColors.appBackground
        }

        tabBarController.tabBar.unselectedItemTintColor = DSColors.gray
    }

    private func presentAddIncomeModally() {
        
        let addIncomeVC = navigationControllers[TabIndex.addIncome.rawValue].viewControllers.first ?? viewFactory.makeAddIncomeViewController()
        let navController = UINavigationController(rootViewController: addIncomeVC)
        navController.modalPresentationStyle = .pageSheet
        navController.configureNavigationBar()

        configureSheetPresentation(for: navController)

        tabBarController.present(navController, animated: true)
    }

    private func configureSheetPresentation(for navigationController: UINavigationController) {
        guard let sheet = navigationController.sheetPresentationController else { return }
        navigationController.navigationBar.prefersLargeTitles = false
        sheet.detents = [.medium(), .large()]
        sheet.selectedDetentIdentifier = .medium
        sheet.prefersGrabberVisible = true
        sheet.preferredCornerRadius = 20
        sheet.largestUndimmedDetentIdentifier = nil

        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = tabBarController.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

    //MARK: - UITabBarControllerDelegate

extension MainCoordinator: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard viewController == navigationControllers[TabIndex.addIncome.rawValue] else {
            return true
        }

        if #available(iOS 26, *) {
            presentAddIncomeModally()
        }

        return false
    }
}
