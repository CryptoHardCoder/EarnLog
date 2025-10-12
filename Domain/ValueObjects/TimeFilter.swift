//
//  File.swift
//  JobData
//
//  Created by M3 pro on 17/07/2025.
//

import Foundation

enum TimeFilter: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    
    var localizedTitle: String {
           switch self {
           case .day: return "filter_day".localized
           case .week: return "filter_week".localized
           case .month: return "filter_month".localized
        }
    }
    
    func daysAmount(reference: Date = Date()) -> Int {
        let calendar = Calendar.current
        switch self {
        case .day: return 1
        case .week:
            let start = calendar.dateInterval(of: .weekOfYear, for: reference)?.start ?? reference
            let diff = calendar.dateComponents([.day], from: start, to: reference).day ?? 0
            return diff + 1
        case .month:
            let start = calendar.dateInterval(of: .month, for: reference)?.start ?? reference
            let diff = calendar.dateComponents([.day], from: start, to: reference).day ?? 0
            return diff + 1
        }
    }
}
