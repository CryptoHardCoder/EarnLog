//
//  Double + ext.swift
//  EarnLog
//
//  Created by M3 pro on 18/10/2025.
//
import Foundation

extension Double {
    
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
//        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()
    
    var formattedWithSpaces: String {
        return Self.numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
