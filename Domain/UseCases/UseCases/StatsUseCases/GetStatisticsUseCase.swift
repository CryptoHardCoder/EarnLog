//
//  GetStatisticsUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//
import Foundation

protocol GetStatisticsUseCase {
    func execute(for items: [IncomeEntry]) -> DataSummary
}

final class GetStatisticsUseCaseImpl: GetStatisticsUseCase {
    private let incomeManager: IncomeManagerProtocol
    private let statisticsCalculator: StatisticsCalculator
    
    init(incomeManager: IncomeManagerProtocol, statisticsCalculator: StatisticsCalculator) {
        self.incomeManager = incomeManager
        self.statisticsCalculator = statisticsCalculator
    }
    
    func execute(for items: [IncomeEntry]) -> DataSummary {
        let items = incomeManager.getAllItems()
        return statisticsCalculator.getStatistics(for: items)
    }
}
