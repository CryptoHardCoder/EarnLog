//
//  ExportSummary.swift
//  EarnLog
//
//  Created by M3 pro on 28/08/2025.
//
import Foundation

// MARK: - Структура для итогов
struct DataSummary {
    let totalCount: Int           // Общее количество
    let totalVolume: Double       // Общий объем
    let paidVolume: Double        // Объем рассчитанных
    let unpaidVolume: Double      // Объем не рассчитанных
    
    init<T: Exportable>(from items: [T]) {
        self.totalCount = items.count
        self.totalVolume = items.reduce(0) { $0 + $1.price }
        self.paidVolume = items.filter { $0.isPaid }.reduce(0) { $0 + $1.price }
        self.unpaidVolume = items.filter { !$0.isPaid }.reduce(0) { $0 + $1.price }
    }
}
