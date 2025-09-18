//
//  ArchiveMetadata.swift
//  JobData
//
//  Created by M3 pro on 27/07/2025.
//

import UIKit

// MARK: - Модель для архивных данных (остается для метаданных)
/// Структура для хранения метаданных архива
struct ArchiveMetadata: Codable {
    let year: Int           // Год архива
    let month: Int          // Месяц архива
    let itemsCount: Int     // Количество товаров в архиве
    let fileName: String // Имя CSV файла с данными
    let createdAt: Date     // Дата создания архива
    
    var monthDisplayName: (Locale) -> String {
        return { locale in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "LLLL yyyy" // LLLL — полное название месяца
            dateFormatter.locale = locale
            
            let calendar = Calendar.current
            let date = calendar.date(from: DateComponents(year: year, month: month)) ?? Date()
            return dateFormatter.string(from: date).capitalized
        }
    }
}
