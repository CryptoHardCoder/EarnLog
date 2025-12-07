//
//  Coordinator.swift
//  EarnLog
//
//  Created by M3 pro on 03/11/2025.
//

import UIKit
import OSLog

protocol Coordinator: AnyObject {

    var childCoordinators: [Coordinator] { get set }

    var viewFactory: ViewControllersFactoryProtocol { get }

    func start()

}

extension Coordinator {

    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)

        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "Child added. Child coordinators total: \(childCoordinators.count)")
        Logger.coordinator.debug("\(logMessage, align: .right(columns: 50), privacy: .public)")
    }

    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }

        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "Child removed. Child coordinators total: \(childCoordinators.count)")
        Logger.coordinator.debug("\(logMessage, align: .right(columns: 50), privacy: .public)")
    }

}
