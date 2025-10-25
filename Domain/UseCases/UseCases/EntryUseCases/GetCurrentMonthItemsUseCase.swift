//
//  GetCurrentMonthItemsUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 12/10/2025.
//

import Foundation

protocol GetCurrentMonthItemsUseCase {
    func execute() async throws -> [IncomeEntry]
}

final class GetCurrentMonthItemsUseCaseImpl: GetCurrentMonthItemsUseCase {
    
    private let incomeManager: IncomeManagerProtocol
    
    init(incomeManager: IncomeManagerProtocol) {
        self.incomeManager = incomeManager
    }
    
    func execute() async throws -> [IncomeEntry] {
        let allItems = try await incomeManager.getAllItems()
        return DataFilter.getCurrentMonthItems(items: allItems)
    }
    
    
}
