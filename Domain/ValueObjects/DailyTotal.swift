//
//  DailyTotal.swift
//  EarnLog
//
//  Created by M3 pro on 26/09/2025.
//
import Foundation

struct DailyTotal: Identifiable {
    let id = UUID()
    let date: Date
    let totalPrice: Double
}

extension DailyTotal {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
}
