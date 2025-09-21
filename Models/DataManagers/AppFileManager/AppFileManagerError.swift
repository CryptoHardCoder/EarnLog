//
//  AppFileManagerError.swift
//  EarnLog
//
//  Created by M3 pro on 21/09/2025.
//
import Foundation

enum AppFileManagerError: Error, LocalizedError {
    case loadError(underlying: Error)
    case saveError(underlying: Error)
    case folderCreationFailed(path: String)
    case fileNotFound(name: String)
    case itemNotFound(id: UUID)
    case invalidData
    case jsonError(JsonError)
    
    var errorDescription: String? {
        switch self {
        case .loadError(let error):
            return "Failed to load data: \(error.localizedDescription)"
        case .saveError(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .folderCreationFailed(let path):
            return "Failed to create file at path: \(path)"
        case .fileNotFound(let name):
            return "File not found: \(name)"
        case .itemNotFound(let id):
            return "Item not found with ID: \(id.uuidString)"
        case .invalidData:
            return "Invalid data"
        case .jsonError(let jsonError):
            return jsonError.errorDescription
        }
    }
}
