//
//  ArchiveReviewViewModel.swift
//  EarnLog
//
//  Created by M3 pro on 15/08/2025.
//

import Foundation

final class ArchiveReviewViewModel: MemoryTrackable {
    
    private let fileManager = AppCoreServices.shared.appFileManager
    private let archiveManager = AppCoreServices.shared.archiveManager
    private let statsManager = AppCoreServices.shared.statisticsCalculator
    
    private let year: Int
    private let month: Int
    private let metaData: ArchiveMetadata
    
    var itemsForCell: [IncomeEntry]
    
    init(year: Int, month: Int, metaData: ArchiveMetadata) {
        self.year = year
        self.month = month
        self.metaData = metaData
        
        let items = archiveManager.getItemsForMonthPDF(year: year, month: month)
        self.itemsForCell = items.sorted(by: { $0.date > $1.date })
        
        if itemsForCell.isEmpty {
            print("⚠️ Предупреждение: Не найдены данные для \(month)/\(year)")
        }
        trackCreation()
    }
    
    func getItemsTotal() -> CarStatistics {
        guard !itemsForCell.isEmpty else {
            print("⚠️ Нет данных для расчета статистики")
            return CarStatistics(total: 0, paid: 0, unPaid: 0, dailyAverage: 0) // Предполагаемая структура
        }
        
        return statsManager.getStatistics(for: itemsForCell, timeFilter: .month)
    }
    
//    func getFileUrlToExport() -> URL {
//        let fileUrl = archiveManager.csvArchivesFolderURL.appending(path: metaData.fileName)
//        
//        if !FileManager.default.fileExists(atPath: fileUrl.path) {
//            print("❌ Файл для экспорта не найден: \(fileUrl.path)")
//        }
//        
//        return fileUrl
//    }

    var hasValidData: Bool {
        return !itemsForCell.isEmpty
    }
    
    var displayTitle: String {
        let monthName = "\(month)"
        return "\(monthName) \(year)"
    }
    
    deinit {
        trackDeallocation() // для анализа на memory leaks
    }
}
