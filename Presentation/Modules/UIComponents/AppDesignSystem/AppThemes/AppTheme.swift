//
//  AppTheme.swift
//  EarnLog
//
//  Created by M3 pro on 22/11/2025.
//
import UIKit

enum AppTheme: Int, CaseIterable {
    case light
    case dark
    case system

    var name: String {
        switch self {
            case .light:
                return "Light"
            case .dark:
                return "Dark"
            case .system:
                return "System"
        }
    }
}

struct AppThemeTrait: UITraitDefinition {
    static var defaultValue: AppTheme = .light
    static var affectsColorAppearance: Bool = true
    static var name: String = "Theme"
    static var identifier: String = Bundle.main.bundleIdentifier!
}
