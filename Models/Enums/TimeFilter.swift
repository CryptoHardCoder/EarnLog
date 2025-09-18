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
}
