//
//  DataProvider.swift
//  EarnLog
//
//  Created by M3 pro on 16/09/2025.
//

import Foundation

protocol DataProvider {
    
    func getAllItems() -> [IncomeEntry]
    
    func addNewItem(_ item: IncomeEntry)
    
    func deleteItem (withId id: UUID)
    
    func updateItem(for id: UUID?, for ids: [UUID]?, newCar: String?, newPrice: Double?, newDate: Date?, newStatus: Bool?, newSource: IncomeSource?)
    
    
    func saveItems()
    
    
    
}

