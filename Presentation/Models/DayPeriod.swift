//
//  DayPeriod.swift
//  EarnLog
//
//  Created by M3 pro on 13/09/2025.
//

import Foundation

enum DayPeriod: String, CaseIterable {
    case morning
    case afternoon
    case evening
    case night
    
    var displayText: String {
        switch self {
            case .morning:
                return "morning_greeting".localized
            case .afternoon:
                return "afternoon_greeting".localized
            case .evening:
                return "evening_greeting".localized
            case .night:
                return "night_greeting".localized
        }
    }
    
    private static func getCaseFrom(hour: Int) -> DayPeriod{
        switch hour {
            case 5..<12:
                return .morning
            case 12..<17: 
                return .afternoon
            case 17..<21:
                return .evening
            default :
                return .night
        }
    }
    
    static func fromNow() -> DayPeriod{
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: .now)
        return getCaseFrom(hour: hour)
    }
}
