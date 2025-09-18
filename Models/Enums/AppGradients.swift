//
//  AppGradients.swift
//  EarnLog
//
//  Created by M3 pro on 31/08/2025.
//
import UIKit

enum AppGradients {
    case greenForCard
    case greenForChart

    func layer(frame: CGRect, traits: UITraitCollection? = nil, view: UIView? = nil) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        let lightThemeColors = [ UIColor(hex: "0F8046").cgColor,
                                 UIColor(hex: "92F8CA").cgColor]
        
        let darkThemeColors = [UIColor(hex: "#0F673A").cgColor,
                               UIColor(hex: "#223C30").cgColor]
        // Определяем тему
        let userTraits: UITraitCollection
        if let traits = traits {
            userTraits = traits
        } else if #available(iOS 17.0, *), 
                  let screen = view?.window?.windowScene?.screen {
                userTraits = screen.traitCollection
        } else {
            userTraits = UIScreen.main.traitCollection
        }

        let isDark = userTraits.userInterfaceStyle == .dark

        switch self {
        case .greenForCard:
            if isDark {
                // Тёмная тема
                gradient.colors = darkThemeColors
                gradient.startPoint = CGPoint(x: 0.9, y: 0.0)
                gradient.endPoint   = CGPoint(x: 0.1, y: 1.0)
                
                print("// Тёмная тема")
            } else {
                // Светлая тема
                gradient.colors = lightThemeColors
                gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
                gradient.endPoint   = CGPoint(x: 1.0, y: -0.5)
                print("// Светлая тема")
            }
        case .greenForChart:
            gradient.colors = [lightThemeColors[1], lightThemeColors[0]] // [светлый "#0F8046", темный "#92F8CA"]
            gradient.startPoint = CGPoint(x: 0.0, y: 1.0) 
            gradient.endPoint   = CGPoint(x: 0.8, y: 1.0)       
        }
        gradient.type = .axial
        gradient.locations = [0.0, 1.0]
        return gradient
    }
}
