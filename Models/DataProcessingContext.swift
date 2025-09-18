//
//  DataProcessingContext.swift
//  EarnLog
//
//  Created by M3 pro on 28/08/2025.
//
import Foundation


// MARK: - Контекст данных для обработки
class DataProcessingContext<T: Exportable> {
    let items: [T]                    
    let configuration: FileProcessingConfiguration  
    let period: TimeFilter            
    let summary: DataSummary        
    
    init(items: [T], configuration: FileProcessingConfiguration, period: TimeFilter) {
        self.items = items.sorted { $0.date < $1.date }
        self.configuration = configuration
        self.period = period
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
}
