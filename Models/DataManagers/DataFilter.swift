//
//  DataFilter.swift
//  EarnLog
//
//  Created by M3 pro on 16/09/2025.
//

import Foundation

final class DataFilter {
    
    private var allItems: [IncomeEntry] {
        dataProvider.getAllItems()
    }
    
    private let dataProvider: DataProvider
    
    init(dataProvider: DataProvider){
        self.dataProvider = dataProvider
    }
    
    
    func getFilteredItems(for filter: TimeFilter, source: IncomeSource? = nil) -> [IncomeEntry] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let nowDate = Date()
        
        // Сначала фильтруем по времени
        let timeFilteredItems: [IncomeEntry]
        
        switch filter {
        case .day:
            timeFilteredItems = allItems.filter { calendar.isDate($0.date, inSameDayAs: nowDate) }
        case .week:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: nowDate)
                else { return [] }
            timeFilteredItems = allItems.filter { weekInterval.contains($0.date) }
        case .month:
            guard let monthInterval = calendar.dateInterval(of: .month, for: nowDate) else { return [] }
            timeFilteredItems = allItems.filter { monthInterval.contains($0.date) }
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
}
