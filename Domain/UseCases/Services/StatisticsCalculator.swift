//
//  StatisticsCalculator.swift
//  EarnLog
//
//  Created by M3 pro on 16/09/2025.
//
import Foundation

enum StatisticsCalculator {
    
    static func getCurrentMonthStats(from items: [IncomeEntry]) -> DataSummary {
        let today = Date()
        let calendar = Calendar.current
        
        let currentMonthAndYear = calendar.dateComponents([.month, .year], from: today)
        
        let currentMonthItems = items.filter { item in
            let itemMonthAndYear = calendar.dateComponents([.month, .year], from: item.date)
            return itemMonthAndYear == currentMonthAndYear
        }
        
        return DataSummary(from: currentMonthItems)
    }
    
    static func getItemsForSource(from items: [IncomeEntry], source: IncomeSource) -> [IncomeEntry] {
        items.filter { $0.source == source }
    }
    
    static func getTotalWithSources(in items: [IncomeEntry]) -> [(String, Double)] {
        var arrayForReturn = [(source: String, totalVolume: Double)]()
        let sourcesInItems = Set(items.map { $0.source })
        for source in sourcesInItems {
            let sourceString = source.displayName
            let itemsForSource = getItemsForSource(from: items, source: source)
            let totalVolume = itemsForSource.reduce(0) { $0 + $1.price }
            arrayForReturn.append((source: sourceString, totalVolume: totalVolume))
        }
        return arrayForReturn.sorted { $0.totalVolume > $1.totalVolume }
    }
    
    static func getDailyTotal(from items: [IncomeEntry]) -> [DailyTotal] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: items) { calendar.startOfDay(for: $0.date) }
        
        return grouped.map { (date, entries) in
            DailyTotal(date: date, totalPrice: entries.reduce(0) { $0 + $1.price })
        }.sorted { $0.date < $1.date }
    }
    
    static func getStatistics(for items: [IncomeEntry], timeFilter: TimeFilter) -> EntryStatistics {
        let totalPrice = items.reduce(0) { $0 + $1.price }
        let paid = items.filter { $0.isPaid }.reduce(0) { $0 + $1.price }
        let unpaid = items.filter { !$0.isPaid }.reduce(0) { $0 + $1.price }
        
        let dailyAverage: Double
        if items.isEmpty {
            dailyAverage = 0
        } else {
            dailyAverage = totalPrice / Double(timeFilter.daysAmount())
        }
        
        return EntryStatistics(total: totalPrice, paid: paid, unPaid: unpaid, dailyAverage: dailyAverage)
    }
    // Метод для получения итоговой статистики без экспорта
    static func getStatistics(for items: [IncomeEntry]) -> DataSummary {
        return DataSummary(from: items)
    }

}
