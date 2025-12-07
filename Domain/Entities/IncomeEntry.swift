//
//  IncomeEntry.swift
//  JobData
//
//  Created by M3 pro on 14/07/2025.
//
import Foundation

// MARK: - Модель
struct IncomeEntry: Codable, Identifiable, Hashable {
    let id: UUID
    let date: Date
    let jobTitle: String
    let jobDescription: String?
    let price: Double
    let isPaid: Bool
    var source: IncomeSource
    
    init(date: Date, jobTitle: String, jobDescription: String?, price: Double, isPaid: Bool = false, source: IncomeSource) {
        self.id = UUID()
        self.date = date
        self.jobTitle = jobTitle
        self.jobDescription = jobDescription
        self.price = price
        self.isPaid = isPaid
        self.source = source
        
    }
}


//// MARK: - Расширение IncomeEntry для поддержки экспорта
//extension IncomeEntry: Exportable {
//    // Заголовки колонок для CSV и PDF
//    var csvHeaders: [String] {
//        ["date".localized, "make".localized, "price".localized, "status_pay".localized, "source".localized]
//    }
//    
//    // Данные строки для CSV и PDF
//    var csvRow: [String] {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd.MM.yyyy"
//        
//        return [
//            dateFormatter.string(from: date),                         // Форматируем дату
//            jobDescription,                                           
//            String(format: "%.2f", price),                           // Цена с 2 знаками после запятой
//            isPaid ? "paid_for_cell".localized : "unPaid_for_cell".localized,  // Статус оплаты
//            source.displayName                                        // Источник дохода
//        ]
//    }
//}




