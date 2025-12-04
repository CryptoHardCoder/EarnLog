//
//  ThemeColors.swift
//  EarnLog
//
//  Created by M3 pro on 30/11/2025.
//

import UIKit


protocol ThemeColorsProtocol {
    // MARK: Brand
    var primary: UIColor { get }
    var primaryVariant: UIColor { get }

    // MARK: Background
    var background: UIColor { get }
    var backgroundSecondary: UIColor { get }

    // MARK: Text
    var textPrimary: UIColor { get }
    var textSecondary: UIColor { get }
    var textTertiary: UIColor { get }
    var textQuaternary: UIColor { get }

    // MARK: Status
    var success: UIColor { get }
    var warning: UIColor { get }
    var error: UIColor { get }
    var info: UIColor { get }

    // MARK: Special
    var gray: UIColor { get }
    var white: UIColor { get }
    var black: UIColor { get }
    var price: UIColor { get }
    var itemCellsBackground: UIColor { get }
    var shadowColor: UIColor { get }

    // MARK: Component-Specific
    var card: CardColors { get }
    var monthlyGoal: MonthlyGoalColors { get }
    var stats: StatsColors { get }
    var button: ButtonColors { get }
    var alert: AlertColors { get }
}
