//
//  ArchivePeriod.swift
//  EarnLog
//
//  Created by M3 pro on 30/09/2025.
//
import Foundation

// MARK: - Supporting Types
struct ArchivePeriod {
    let year: Int
    let month: Int
    let itemsCount: Int
    let fileName: String?
    let format: FileFormat?
    let fileURL: String?
    
//    init(
//        year: Int, 
//        month: Int, 
//        itemsCount: Int, 
//        fileName: String?,
//        format: FileFormat?, 
//        fileURL: String?
//    ) {
//        self.year = year
//        self.month = month
//        self.itemsCount = itemsCount
//        self.fileName = fileName
//        self.format = format
//        f
//    }
    
    var archiveNeeded: Bool {
        let calendar = Calendar.current
        let now = Date()
        return year != calendar.component(.year, from: now) ||
               month != calendar.component(.month, from: now)
    }
    
    var displayName: String {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let date = calendar.date(from: components) else {
            return "\(month).\(year)"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
