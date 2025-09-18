//
//  Exportable.swift
//  EarnLog
//
//  Created by M3 pro on 28/08/2025.
//

import Foundation

// MARK: - Протокол для экспортируемых данных
protocol Exportable {
    var csvHeaders: [String] { get }  // Заголовки колонок для CSV
    var csvRow: [String] { get }      // Данные строки для CSV
    var date: Date { get }            // Дата для сортировки
    var price: Double { get }         // Цена для расчета итогов
    var isPaid: Bool { get }          // Статус оплаты для расчета итогов
}
