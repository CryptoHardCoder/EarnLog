//
//  Notification + ext.swift
//  JobData
//
//  Created by M3 pro on 20/07/2025.
//

import UIKit
import Foundation

// MARK: - Notification для обновления UI
extension Notification.Name {
    static let dataDidUpdate = Notification.Name("dataDidUpdate")
    static let recoveryFiles = Notification.Name("recoveryFiles")
}

