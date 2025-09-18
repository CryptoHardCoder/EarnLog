//
//  StatsViewModel.swift
//  EarnLog
//
//  Created by M3 pro on 31/07/2025.
//

import Foundation
import UIKit

class StatsViewModel: MemoryTrackable{
    
    var groupedItems = [DailyTotal]()
    
    private let statsManager = AppCoreServices.shared.statisticsCalculator
    
    private let dataFilter = AppCoreServices.shared.dataFilter
    
    private let appFileManager = AppCoreServices.shared.appFileManager
    
//    var filteredItemsWithSource: [IncomeEntry] = []
    
    var sources: [IncomeSource] {
        appFileManager.sources
    }
    
    var source: IncomeSource? = nil
    
    var filteredItems: [IncomeEntry] = []
    
    var currentFilterInterval: TimeFilter = .day
    
    var targetValue: Double {
        return UserDefaults.standard.double(forKey: "targetValue")
    }
    
    var onDataChanged: (() -> Void)?
    
    init() {
        trackCreation()
    }
    
    func refreshData(){
        filteredItems = dataFilter.getFilteredItems(for: currentFilterInterval, source: source)
//        filteredItemsWithSource = AppFileManager.shared.getFilteredItemsWithSource(
//                                                                        filteredItems: filteredItems,
//                                                                        source: source)
        groupedItems = statsManager.getDailyTotal(items: filteredItems)
        onDataChanged?()
    }
    
    func changeSegmentFilter(index: Int){
        let filters = TimeFilter.allCases
        guard index < filters.count else { return }
        currentFilterInterval = filters[index]
        refreshData()
    }
    
    func getStats() -> CarStatistics {
        return statsManager.getStatistics(for: filteredItems, timeFilter: currentFilterInterval)
    }
    
    deinit {
        trackDeallocation() // для анализа на memory leaks
    }
    
//    func getItemsWithSource(){
//        filteredItems = AppFileManager.shared.getFilteredItems(for: currentFilterInterval)
//        filteredItemsWithSource = AppFileManager.shared.getFilteredItemsWithSource(
//                                                                        filteredItems: filteredItems,
//                                                                        source: source)
////        print(filteredItemsWithSource)
//        refreshData()
//    }

    
}


//
//class StatsViewModel{
//    
//    var groupedItems = [DailyTotal]()
//    
//    var sources = AppFileManager.shared.sources
//    
//    var source: IncomeSource = .notSelected
//    
//    var filteredItems: [IncomeEntry] = []
//    
//    var currentFilterInterval: TimeFilter = .day
//    
//    var targetValue: Double {
//        return UserDefaults.standard.double(forKey: "targetValue")
//    }
//    
//    var onDataChanged: (() -> Void)?
//    
////    init(sources: [IncomeSource] = [
////            IncomeSource(id: UUID(), source: "Основная работа"),
////            IncomeSource(id: UUID(), source: "Выездные точки"),
////            IncomeSource(id: UUID(), source: "Общее")
////    ]) {
////
//////        self.sources = sources
////
////        }
//    
//    func refreshData(){
//        filteredItems = AppFileManager.shared.getFilteredItems(for: currentFilterInterval)
//        groupedItems = AppFileManager.shared.getDailyTotal(items: filteredItems)
//        onDataChanged?()
//    }
//    
//    func changeSegmentFilter(index: Int){
//        let filters = TimeFilter.allCases
//        guard index < filters.count else { return }
//        currentFilterInterval = filters[index]
//        refreshData()
//    }
//    
//    func getStats() -> CarStatistics {
//        return AppFileManager.shared.getStatics(for: filteredItems, timeFilter: currentFilterInterval)
//    }
//    
//
//    func addSource(sourceString: String){
//        let newSource = IncomeSource.SideJob.init(id: UUID(), name: sourceString, isCustom: true)
//        SideJobStorage.shared.saveCustomJobs(sideJob: newSource)
//        
//    }
//    
//}

