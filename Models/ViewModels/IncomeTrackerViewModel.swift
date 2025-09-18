//
//  IncomeTrackerViewModel.swift
//  EarnLog
//
//  Created by M3 pro on 31/07/2025.
//

import Foundation

class IncomeTrackerViewModel: MemoryTrackable {
    
    var sources: [IncomeSource]
    
    var groupedItems: [DailyTotal] = []
    
    var allItems: [IncomeEntry] = []
    
    init(sources: [IncomeSource] = []) {
        
        self.sources = sources
        trackCreation() 
        
        }
    
//    func addSource(sourceString: String){
//       let newItem = IncomeSource(id: UUID(), source: sourceString)
//        sources.append(newItem)
//    }
    
//    func getGroupedItems(){
//       groupedItems = AppFileManager.shared.getDailyTotal(items: allItems)
//    }
    
    deinit {
        trackDeallocation() // для анализа на memory leaks
    }
    
}

