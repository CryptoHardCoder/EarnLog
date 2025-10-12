//
//  FileHandlerError.swift
//  EarnLog
//
//  Created by M3 pro on 26/09/2025.
//
import Foundation

// MARK: - Ошибки экспорта
enum FileHandlerError: Error {
    case fileCreationFailed        // Не удалось создать файл
    case encodingFailed           // Ошибка кодирования данных
    case directoryCreationFailed  // Ошибка создания папки
    case fileNotFound(name: String)
    case unExpected
    case invalidPath
    case incompatibleStorageTypes
    case cloudUploadNotImplemented
    case contentCreationFailed
    
    var localizedDescription: String {
        switch self {
            case .fileCreationFailed: return "error_create_file".localized
            case .encodingFailed: return "error_encode_data".localized
            case .directoryCreationFailed: return "error_create_folder".localized
            case .fileNotFound(name: let name): return "File not found: \(name)"
            case .unExpected:
                return "Un Expected fail"
            case .invalidPath:
                return ""
            case .incompatibleStorageTypes:
                return ""
            case .cloudUploadNotImplemented:
                return ""
            case .contentCreationFailed:
                return ""
        }
    }
}
