//
//  ThemeProvider.swift
//  EarnLog
//
//  Created by M3 pro on 22/11/2025.
//

import UIKit

enum ThemeProvider {

    static func colors(for theme: AppTheme) -> ThemeColorsProtocol {
        switch theme {
            case .light: return LightThemeColors()
            case .dark: return DarkThemeColors()
            case .system:
                let style = UIScreen.main.traitCollection.userInterfaceStyle

                switch style {
                    case .dark:
                        return DarkThemeColors()
                    default:
                        return LightThemeColors()
                }
        }
    }
}

