//
//  GetAllItemsUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//
import Foundation 

protocol GetAllItemsUseCase {
    func execute() async throws -> [IncomeEntry]
}

final class GetAllItemsUseCaseImpl: GetAllItemsUseCase {
    private let incomeManager: IncomeManagerRepository
    
    init(incomeManager: IncomeManagerRepository) {
        self.incomeManager = incomeManager
    }
    
    func execute() async throws -> [IncomeEntry] {
        try await incomeManager.getAllItems()
    }
}
