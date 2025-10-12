//
//  DataProcessingContext.swift
//  EarnLog
//
//  Created by M3 pro on 28/08/2025.
//
import Foundation


// MARK: - Контекст данных для обработки
class DataProcessingContext {
    let items: [IncomeEntry]                    
    let configuration: FileConfiguration            
    let summary: DataSummary        
    
    init(items: [IncomeEntry], configuration: FileConfiguration) {
        self.items = items.sorted { $0.date < $1.date }
        self.configuration = configuration
        self.summary = DataSummary(from: self.items)
    }
    
    // Получаем диапазон дат
    var dateRange: (from: Date?, to: Date?) {
        (items.first?.date, items.last?.date)
    }
    
    // Генерируем имя файла на основе операции и дат
    var fileName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let operationPrefix = configuration.operation == .export ? "Exported" : "Archive"
        
        guard let fromDate = dateRange.from,
              let toDate = dateRange.to else {
            return "\(operationPrefix)_Data_\(Date().timeIntervalSince1970)"
        }
        
        if operationPrefix == "Archive"{
            let month = Calendar.current.component(.month, from: fromDate )
            let year = Calendar.current.component(.year, from: fromDate)
            return "\(operationPrefix)_Data_For_\(month).\(year)"
        } else {
            let fromString = dateFormatter.string(from: fromDate)
            let toString = dateFormatter.string(from: toDate)
            
            return (fromString == toString) 
                ? "Exported_Data_For_\(fromString)"
                : "Exported_Data_For_\(fromString)_-_\(toString)"
        }

    }
    
    // Генерируем заголовок документа
    var displayTitle: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        guard let fromDate = dateRange.from,
              let toDate = dateRange.to else {
            return configuration.title
        }
        
        let fromString = dateFormatter.string(from: fromDate)
        let toString = dateFormatter.string(from: toDate)
        
        return (fromString == toString)
            ? "\(configuration.title) \(fromString)"
            : "\(configuration.title) \(fromString) - \(toString)"
    }
    
    // Заголовки колонок для CSV и PDF
    var columnHeaders: [String] {
        ["date".localized, "make".localized, "price".localized, "status_pay".localized, "source".localized]
    }
    
    func stringsForRow(item: IncomeEntry) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return [
            dateFormatter.string(from: item.date),                         // Форматируем дату
            item.jobDescription ?? "",                                           
            String(format: "%.2f", item.price),                           // Цена с 2 знаками после запятой
            item.isPaid ? "paid_for_cell".localized : "unPaid_for_cell".localized,  // Статус оплаты
            item.source.displayName                                        // Источник дохода
        ]
    }
//    // Данные строки для CSV и PDF
//    var dataForRow: [String] {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd.MM.yyyy"
//        guard let item = items.first else { return [] }
//        return [
//            dateFormatter.string(from: item.date),                         // Форматируем дату
//            item.jobDescription,                                           
//            String(format: "%.2f", item.price),                           // Цена с 2 знаками после запятой
//            item.isPaid ? "paid_for_cell".localized : "unPaid_for_cell".localized,  // Статус оплаты
//            item.source.displayName                                        // Источник дохода
//        ]
//    }
}
