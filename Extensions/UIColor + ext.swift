//
//  UIColor + ext.swift
//  EarnLog
//  Created by M3 pro on 31/08/2025.
//
import UIKit

extension UIColor {
    // convenience init — удобный (вспомогательный) инициализатор
    // Позволяет создать UIColor по строке вида "#00FF00" или "00FF00"
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        // убираем пробелы/переводы строк по краям
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        // убираем символ #, если он есть
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        // сюда распарсим шестнадцатеричное число
        var rgb: UInt64 = 0
        // Scanner читает строку как HEX и пишет результат в rgb
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        // Достаём из числа компоненты R, G, B (каждая по 8 бит)
        // (0xFF0000) >> 16 — берём первые 8 бит (красный) и сдвигаем вправо
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        // (0x00FF00) >> 8 — средние 8 бит (зелёный) и сдвигаем вправо
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        // 0x0000FF — последние 8 бит (синий)
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        // Вызываем базовый init UIColor с нормализованными компонентами (0…1)
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
