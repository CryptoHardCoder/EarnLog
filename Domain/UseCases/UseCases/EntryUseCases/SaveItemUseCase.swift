//
//  SaveItemUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//
import Foundation

protocol SaveItemUseCase {
    func execute(new item: IncomeEntry) async throws
}

final class SaveItemUseCaseImpl: SaveItemUseCase {
    
    private let incomeManager: IncomeManagerProtocol
    
    init(incomeManager: IncomeManagerProtocol) {
        self.incomeManager = incomeManager
    }
    
    func execute(new item: IncomeEntry) async throws {
        try await incomeManager.addNewItem(item: item)
    }
}
