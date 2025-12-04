//
//  UIColor + ext.swift
//  EarnLog
//  Created by M3 pro on 31/08/2025.
//
import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted).trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        let alpha, red, green, blue: UInt64
        switch hex.count {
            case 3: // RGB (12-bit)
                (alpha, red, green, blue) = (255, (rgb >> 8) * 17, (rgb >> 4 & 0xF) * 17, (rgb & 0xF) * 17)
            case 6: // RGB (24-bit)
                (alpha, red, green, blue) = (255, rgb >> 16, rgb >> 8 & 0xFF, rgb & 0xFF)
            case 8: // ARGB (32-bit)
                (alpha, red, green, blue) = (rgb >> 24, rgb >> 16 & 0xFF, rgb >> 8 & 0xFF, rgb & 0xFF)
            default:
                (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
    }
}
