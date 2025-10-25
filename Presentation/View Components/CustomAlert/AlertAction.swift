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
                    return .alwaysWhite
                case .cancel:
                    return .systemRed.withAlphaComponent(0.8)
                case .destructive:
                    return .systemRed
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
                    return .systemRed
                default:
                    return .systemGray
            }
        }

        var buttonBackgroundColor: UIColor {
            switch self {
                case .baseDefault:
                    return .buttonDefault
                default:
                    return .alwaysWhite
            }
        }
    }
}
