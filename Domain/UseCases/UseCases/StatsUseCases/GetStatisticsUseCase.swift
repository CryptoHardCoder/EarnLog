//
//  GetStatisticsUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//
import Foundation

protocol GetStatisticsUseCase {
    func execute(for items: [IncomeEntry]) async throws -> DataSummary
}

final class GetStatisticsUseCaseImpl: GetStatisticsUseCase {
    private let incomeManager: IncomeManagerRepository
    
    init(incomeManager: IncomeManagerRepository) {
        self.incomeManager = incomeManager
    }
    
    func execute(for items: [IncomeEntry]) async throws -> DataSummary {
        let items = try await incomeManager.getAllItems()
        return StatisticsCalculator.getStatistics(for: items)
    }
}
