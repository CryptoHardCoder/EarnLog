//
//  Helpers.swift
//  EarnLog
//
//  Created by M3 pro on 31/07/2025.
//

//typealias Statistics = (total: Double, paid: Double, unPaid: Double, dailyAverage: Double)
import Foundation

/// Создает содержимое CSV файла из массива товаров
func createCSVContent(
    from items: [IncomeEntry], 
    title: String,
    dateFormat: String = "dd.MM.yyyy"
) -> String {
    
    guard !items.isEmpty else { return "" }
    
    // Создаем заголовок
    let csvTitle = title
    var csvContent = "\(csvTitle)\n\("date".localized),\("make".localized),\("price".localized),\("status_pay".localized),\("source".localized)\n"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    for item in items {
        let date = dateFormatter.string(from: item.date)
        let make = escapeCSVField(item.car)
        let price = String(format: "%.2f", item.price)
        let statusPaid = item.isPaid ? "paid_for_cell".localized : "unPaid_for_cell".localized
        let source = escapeCSVField(item.source.displayName)
        
        csvContent += "\"\(date)\",\"\(make)\",\(price),\"\(statusPaid)\",\"\(source)\"\n"
    }
    
    let totalAmount = items.reduce(0) { $0 + $1.price }
    csvContent += "\"\("total_count_amount".localized)\",\"\(items.count)\",\"\(String(format: "%.2f", totalAmount))\""
    
    return csvContent
}


/// Экранирует поля CSV
func escapeCSVField(_ field: String) -> String {
    if field.contains(",") || field.contains("\"") || field.contains("\n") {
        let escapedField = field.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escapedField)\""
    }
    return field
}



/// Получает название месяца на русском языке
func getMonthName(_ month: Int) -> String {
    let monthNames = [
        "january".localized, "february".localized, "march".localized, "april".localized, "may".localized, "june".localized,
        "july".localized, "august".localized, "september".localized, "october".localized, "november".localized, "december".localized
    ]
    
    if month >= 1 && month <= 12 {
        return monthNames[month - 1]
    }
    return "UNKNOWN"
}
