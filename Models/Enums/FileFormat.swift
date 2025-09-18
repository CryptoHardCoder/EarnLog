//
//  ExportFormat.swift
//  EarnLog
//
//  Created by M3 pro on 28/08/2025.
//


import Foundation

// MARK: - Enum для выбора формата экспорта
enum FileFormat: String, CaseIterable {
    case csv    // Экспорт в CSV файл
    case pdf    // Экспорт в PDF файл с брендингом
}

// MARK: - Ошибки экспорта
enum DataProcessingError: Error {
    case noData                     // Нет данных для экспорта
    case fileCreationFailed        // Не удалось создать файл
    case encodingFailed           // Ошибка кодирования данных
    case directoryCreationFailed  // Ошибка создания папки
    
    var localizedDescription: String {
        switch self {
            case .noData: return "error_no_data".localized
            case .fileCreationFailed: return "error_create_file".localized
            case .encodingFailed: return "error_encode_data".localized
            case .directoryCreationFailed: return "error_create_folder".localized
        }
    }
}

//// MARK: - Ошибки обработки данных
//enum DataProcessingError: Error {
//    case noData                     
//    case fileCreationFailed        
//    case encodingFailed           
//    case directoryCreationFailed  
//    
//    var localizedDescription: String {
//        switch self {
//        case .noData: return "Нет данных для обработки"
//        case .fileCreationFailed: return "Не удалось создать файл"
//        case .encodingFailed: return "Ошибка кодирования данных"
//        case .directoryCreationFailed: return "Ошибка создания папки"
//        }
//    }
//}
