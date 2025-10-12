//
//  IncomeManagerProtocol.swift
//  EarnLog
//
//  Created by M3 pro on 16/09/2025.
//
import Foundation

protocol IncomeManagerProtocol {
        
    func getAllItems() async throws -> [IncomeEntry] 
    
    func addNewItem(item: IncomeEntry) async throws
    
    func deleteItem (withId id: UUID) async throws
    
    func updateItem(id: UUID?, ids: [UUID]?, 
                    newTitle: String?, newDescription: String?, 
                    newPrice: Double?, newDate: Date?, 
                    newStatus: Bool?, newSource: IncomeSource?) async throws
    
//    func saveItems() -> Result<Void, IncomeManagerError>

}

//enum IncomeManagerError: Error, LocalizedError {
//    case loadFailed(String)
//    case saveFailed(String) 
//    case itemNotFound(UUID)
//    case invalidData
//    case storageUnavailable
//    
//    var errorDescription: String? {
//        switch self {
//        case .loadFailed(let reason):
//            return "Failed to load data: \(reason)"
//        case .saveFailed(let reason):
//            return "Failed to save data: \(reason)"
//        case .itemNotFound(let id):
//            return "Item not found: \(id.uuidString)"
//        case .invalidData:
//            return "Data is invalid"
//        case .storageUnavailable:
//            return "Storage is not available"
//        }
//    }
//}
