//
//  LoginCoordinator.swift
//  EarnLog
//
//  Created by M3 pro on 03/11/2025.
//

import Foundation
import UIKit

final class LoginCoordinator: Coordinator {

    var childCoordinators: [any Coordinator] = []

    var viewFactory: ViewControllersFactoryProtocol

    var onLoginSuccess: (() -> Void)?

    private let navigationController: UINavigationController

    init(viewFactory: any ViewControllersFactoryProtocol, navigationController: UINavigationController) {
        self.viewFactory = viewFactory
        self.navigationController = navigationController
    }

    func start() {

    }

}
