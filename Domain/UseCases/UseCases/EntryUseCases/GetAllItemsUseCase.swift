//
//  GetAllItemsUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//
import Foundation 

protocol GetAllItemsUseCase {
    func execute() -> [IncomeEntry]
}

final class GetAllItemsUseCaseImpl: GetAllItemsUseCase {
    private let incomeManager: IncomeManagerProtocol
    
    init(incomeManager: IncomeManagerProtocol) {
        self.incomeManager = incomeManager
    }
    
    func execute() -> [IncomeEntry] {
        incomeManager.getAllItems()
    }
}
