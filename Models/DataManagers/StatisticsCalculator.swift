//
//  StatisticsCalculator.swift
//  EarnLog
//
//  Created by M3 pro on 16/09/2025.
//
import Foundation

final class StatisticsCalculator {
    
    private var allItems: [IncomeEntry] {
        dataProvider.getAllItems()
    }
    
    private let dataProvider: DataProvider
    
    init(dataProvider: DataProvider){
        self.dataProvider = dataProvider
    }

    func getLastMonthItems() -> [IncomeEntry]{
        let calendar = Calendar.current
        let lastMonth = calendar.dateComponents([.month], from: .now)
       
        let lastMonthsItems = allItems.filter { item in 
            let itemMonth = calendar.dateComponents([.month], from: item.date)
            if itemMonth != lastMonth {
                return false
            }
            return true
        }
//        print("appDileManager.getLastMonthItems.allItems: \(allItems)")
//        print("appDileManager.getLastMonthItems.lastMonthItems: \(lastMonthsItems)")
        return lastMonthsItems
    }
    
    func getLastMonthStats() -> DataSummary{
        let lastMonthItems = getLastMonthItems()
        return DataSummary(from: lastMonthItems)
    }
    
    func getItemsForSource(items: [IncomeEntry], source: IncomeSource) -> [IncomeEntry]{
        return  items.filter { $0.source == source }
        
    }
    
    func getTotalWithSources(in items: [IncomeEntry]) -> [(String, Int)]{
        for (i, item) in items.enumerated() {
            print("getTotalWithSourcesInItems: \(i).\(item)")
        }
        var arrayForReturn = [(source: String, totalVolume: Int)]()
        let sourcesInItems = Set(items.map { $0.source })
        for source in sourcesInItems {
            let sourceString = source.displayName
            let itemsForSource = getItemsForSource(items: items, source: source)
            let totalVolume = itemsForSource.reduce(0) { $0 + $1.price }
            arrayForReturn.append((source: sourceString, totalVolume: Int(totalVolume)))
        }
        print("arrayForReturn: \(arrayForReturn.sorted { $0.totalVolume > $1.totalVolume })")
        return arrayForReturn.sorted { $0.totalVolume > $1.totalVolume }
    }
    
    func getDailyTotal(items: [IncomeEntry]) -> [DailyTotal]{
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: items) { item in
            calendar.startOfDay(for: item.date)
        }
        
        return grouped.map { (date, entries) in
            DailyTotal(date: date, totalPrice: entries.reduce(0) { $0 + $1.price })
        }.sorted { $0.date < $1.date }
    }
     
    func getStatistics(for items: [IncomeEntry], timeFilter: TimeFilter?) -> CarStatistics {
        let totalPrice = items.reduce(0) { $0 + $1.price }
        let paid = items.filter{$0.isPaid}.reduce(0){$0 + $1.price}
        let unpaid = items.filter{!$0.isPaid}.reduce(0){$0 + $1.price}
        
        let dailyAverage: Double
        
        if items.isEmpty {
            dailyAverage = 0
        } else {
            switch timeFilter {
            case .day:
                // Для дня - среднее по количеству записей (как было)
                dailyAverage = totalPrice / Double(items.count)
                
            case .week:
                // Для недели - делим на количество дней в текущей неделе
                let calendar = Calendar.current
                let now = Date()
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                let daysSinceStartOfWeek = calendar.dateComponents([.day], from: startOfWeek, to: now).day ?? 0
                let daysInCurrentWeek = daysSinceStartOfWeek + 1 // +1 потому что считаем текущий день
                dailyAverage = totalPrice / Double(daysInCurrentWeek)
//                    print("daysInCurrentWeek: \(daysInCurrentWeek)")
//                    print("startOfWeek: \(startOfWeek)")
//                    print("daysSinceStartOfWeek: \(daysSinceStartOfWeek)")
                
            case .month:
                // Для месяца - делим на количество дней в текущем месяце
                let calendar = Calendar.current
                let now = Date()
                let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
                let daysSinceStartOfMonth = calendar.dateComponents([.day], from: startOfMonth, to: now).day ?? 0
                let daysInCurrentMonth = daysSinceStartOfMonth + 1 // +1 потому что считаем текущий день
                dailyAverage = totalPrice / Double(daysInCurrentMonth)
                case .none:
                    dailyAverage = 0
                    
            }
        }
        
        return CarStatistics(total: totalPrice, paid: paid, unPaid: unpaid, dailyAverage: dailyAverage)
    }
    
    // Метод для получения итоговой статистики без экспорта
    func getStatistics(for items: [IncomeEntry]) -> DataSummary {
        return DataSummary(from: items)
    }
}
