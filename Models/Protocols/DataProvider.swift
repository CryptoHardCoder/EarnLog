//
//  DataProvider.swift
//  EarnLog
//
//  Created by M3 pro on 16/09/2025.
//

import Foundation

protocol DataProvider {
    
    func getAllItems() -> AppFileManagerResult<[IncomeEntry]> 
    
    func addNewItem(_ item: IncomeEntry) -> AppFileManagerResult<Void>
    
    func deleteItem (withId id: UUID) -> AppFileManagerResult<Void>
    
    func updateItem(for id: UUID?, for ids: [UUID]?, newCar: String?, newPrice: Double?, newDate: Date?, newStatus: Bool?, newSource: IncomeSource?) -> AppFileManagerResult<Void>
    
    
    func saveItems() -> AppFileManagerResult<Void>
    
    
    
}

