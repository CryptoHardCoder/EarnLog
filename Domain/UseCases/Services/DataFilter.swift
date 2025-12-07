//
//  DataFilter.swift
//  EarnLog
//
//  Created by M3 pro on 16/09/2025.
//

import Foundation

enum DataFilter {
    
    static func getFilteredItems(from items: [IncomeEntry], for filter: TimeFilter, source: IncomeSource? = nil) -> [IncomeEntry] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let nowDate = Date()
        
        // Сначала фильтруем по времени
        let timeFilteredItems: [IncomeEntry]
        
        switch filter {
        case .day:
            timeFilteredItems = items.filter { calendar.isDate($0.date, inSameDayAs: nowDate) }
        case .week:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: nowDate)
                else { return [] }
            timeFilteredItems = items.filter { weekInterval.contains($0.date) }
        case .month:
            guard let monthInterval = calendar.dateInterval(of: .month, for: nowDate) else { return [] }
            timeFilteredItems = items.filter { monthInterval.contains($0.date) }
        }
        
        // Затем фильтруем по источнику (если указан)
        let finalFilteredItems: [IncomeEntry]
        if let source = source {
            finalFilteredItems = timeFilteredItems.filter { $0.source == source }
        } else {
            finalFilteredItems = timeFilteredItems
        }
        
        return finalFilteredItems.sorted { $0.date > $1.date }
    }
    
    static func getItemsForPeriod(items: [IncomeEntry], year: Int, month: Int) -> [IncomeEntry] {
        let calendar = Calendar.current
        
        return items.filter { item in
            let itemYear = calendar.component(.year, from: item.date)
            let itemMonth = calendar.component(.month, from: item.date)
            return itemYear == year && itemMonth == month
        }
    }
    
    static func getCurrentMonthItems(items: [IncomeEntry]) -> [IncomeEntry] {
        let calendar = Calendar.current
        let now = Date.now
        
        return items.filter { item in
            calendar.isDate(item.date, equalTo: now, toGranularity: .month)
        }
    }
}
