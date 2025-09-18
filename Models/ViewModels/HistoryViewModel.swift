//
//  HistoryViewModel.swift
//  EarnLog
//
//  Created by M3 pro on 30/07/2025.
//

import Foundation


class HistoryViewModel: MemoryTrackable{
    
    private var summaryTimeInterval = [String]()
    private(set) var filteredEntries: [IncomeEntry] = [] // Только для чтения извне
    private var currentFilterInterval: TimeFilter = .day
    
    private let statsManager = AppCoreServices.shared.statisticsCalculator
    private let dataFilter = AppCoreServices.shared.dataFilter
    private let dataService = AppCoreServices.shared.dataService
    private let fileManager = AppCoreServices.shared.appFileManager
    
    var onDataChanged: (() -> Void)?
    var exportFile: (() -> Void)?
    // Добавить новый callback для сброса UI состояния
    var onResetUIState: (() -> Void)?
    
    init() {
        refreshData() // Загрузить данные при создании
        trackCreation()
    }
    
    func refreshData() {
        filteredEntries = dataFilter.getFilteredItems(for: currentFilterInterval)
        onDataChanged?()
    }
    
   

    func getAllItemsAndResetUI() {
        filteredEntries = fileManager.getAllItems().sorted(by: { $0.date > $1.date })
        onResetUIState?() // Сбрасываем состояние UI
        onDataChanged?()
    }
    
    
    func exportToFormat(_ format: FileFormat) -> Result< URL, DataProcessingError > {
        let fileURL: URL?
        
        switch format {
        case .csv:
                fileURL = dataService.exportData(filteredEntries, format: .csv, period: currentFilterInterval)
            case .pdf:
            fileURL = dataService.exportData(filteredEntries, format: .pdf, period: currentFilterInterval)
        }

        guard let url = fileURL else {
            return .failure(.noData)
        }
        
        return .success(url)
    }
    
//    func exportToFormat(_ format: ExportFormat) -> Result< URL, ExportError > {
//        let fileURL: URL?
//        
//        switch format {
//        case .csv:
//            fileURL = AppFileManager.shared.exportCSV(items: filteredEntries, period: currentFilterInterval)
//        case .json:
//            fileURL = AppFileManager.shared.exportJSON(items: filteredEntries, period: currentFilterInterval)
//        }
//
//        guard let url = fileURL else {
//            return .failure(.failed)
//        }
//        
//        return .success(url)
//    }
    
    func changeFilterByIndex(_ index: Int){
        let filters = TimeFilter.allCases
        guard index < filters.count else { return }
        currentFilterInterval = filters[index]
        refreshData()
        
        onDataChanged?() // 📢 Говорим View что фильтр изменился
    }
    
    func getTotalToSummaryLabel() -> Double {
        let stats = statsManager.getStatistics(for: filteredEntries, timeFilter: nil)
        return stats.total
    }
    
    func updateItem(entryId: UUID? = nil, entiresIds: [UUID]? = nil, entryCar: String? = nil, entryPrice: Double? = nil, 
                    entryDate: Date? = nil, newStatus: Bool? = nil, entrySource: IncomeSource? = nil){
        fileManager.updateItem(for: entryId,
                                         for: entiresIds,
                                         newCar: entryCar,
                                         newPrice: entryPrice,
                                         newDate: entryDate,
                                         newStatus: newStatus,
                                         newSource: entrySource)
        // Обновляем уведомлением
//        NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
    }
    
    
    func deleteItem(entryId: UUID){
        fileManager.deleteItem(withId: entryId)
//        NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
    }
    
    
    deinit {
        trackDeallocation() // для анализа на memory leaks
    }

}
