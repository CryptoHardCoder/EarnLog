//
//  DSButtonSize.swift
//  EarnLog
//
//  Created by M3 pro on 30/11/2025.
//
import UIKit

enum DSButtonSize {
    case small
    case medium
    case large

    var height: CGFloat {
        switch self {
            case .small: return 36
            case .medium: return 44
            case .large: return 50
        }
    }

    var contentInsets: UIEdgeInsets {
        switch self {
            case .small: return UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            case .medium: return UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
            case .large: return UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        }
    }

    var iconSize: CGFloat {
        switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
        }
    }

    var font: UIFont {
        switch self {
            case .small : return .systemFont(ofSize: 16, weight: .regular)
            case .medium: return .systemFont(ofSize: 18, weight: .semibold)
            case .large: return .systemFont(ofSize: 20, weight: .bold)
        }
    }
}
