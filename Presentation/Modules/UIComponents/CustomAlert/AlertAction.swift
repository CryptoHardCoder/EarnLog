//
//  AlertAction.swift
//  EarnLog
//
//  Created by M3 pro on 23/10/2025.
//

import Foundation
import UIKit

struct AlertAction {
    let title: String
    let style: Style
    let handler: (() -> Void)?

    enum Style {
        case baseDefault
        case cancel
        case destructive

        var textColor: UIColor {
            switch self {
                case .baseDefault:
                    return DSColors.AlertColors.Text.default
                case .cancel:
                    return DSColors.AlertColors.Text.cancel
                case .destructive:
                    return DSColors.AlertColors.Text.destructive
            }
        }

        var font: UIFont {
            switch self {
                case .cancel:
                    return .systemFont(ofSize: 20, weight: .bold)
                default:
                    return .systemFont(ofSize: 20, weight: .semibold)
            }
        }

        var buttonBorderColor: UIColor {
            switch self {
                case .destructive:
                    return DSColors.AlertColors.ButtonBorder.destructive
                case .cancel:
                    return DSColors.AlertColors.ButtonBorder.default
                default:
                    return .clear
            }
        }

        var buttonBackgroundColor: UIColor {
            switch self {
                case .baseDefault:
                    return DSColors.AlertColors.ButtonBackground.primary
                default:
                    return DSColors.AlertColors.ButtonBackground.default
            }
        }
    }
}
