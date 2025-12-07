//
//  DataProviderImplError.swift
//  EarnLog
//
//  Created by M3 pro on 21/09/2025.
//
import Foundation

enum IncomeManagerError: Error, LocalizedError {
    case loadError(underlying: Error)
    case saveError(underlying: Error)
    case itemNotFound(id: UUID)
    
    var errorDescription: String? {
        switch self {
        case .loadError(let error):
            return "Failed to load data: \(error.localizedDescription)"
        case .saveError(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .itemNotFound(let id):
            return "Item not found with ID: \(id.uuidString)"
        }
    }
}
