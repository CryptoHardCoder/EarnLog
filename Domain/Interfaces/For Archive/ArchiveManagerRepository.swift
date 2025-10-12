//
//  ArchiveService.swift
//  EarnLog
//
//  Created by M3 pro on 30/09/2025.
//
import Foundation

protocol ArchiveManagerRepository {
    func checkArchiveOnAppStart() async
    func loadItemsForPeriod(year: Int, month: Int) async -> Result<[IncomeEntry], ArchiveServiceError>
    func getAvailablePeriods() async -> [ArchivePeriod]
}
