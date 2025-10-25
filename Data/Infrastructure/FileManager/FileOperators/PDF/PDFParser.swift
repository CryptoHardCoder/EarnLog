//
//  PDFParser.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//

import Foundation
import PDFKit

final class PDFParser: FileParser {
    
    private let sideJobsManager: SideJobManagerRepository
    
    init(sideJobsManager: SideJobManagerRepository) {
        self.sideJobsManager = sideJobsManager
    }

    // MARK: - Configuration
    private struct ParsingConfig {
        static let datePattern = #"(\d{2}\.\d{2}\.\d{4})"#
        static let pricePattern = #"(\d+(?:\.\d{2})?)"#
        static let dateFormat = "dd.MM.yyyy"
        
        static let servicePrefixes = [
            "iTracker", "Archived Data", "Exported Data", "Page", "Generated:",
            "Итоги:", "Общее количество:", "Общий объем:", "Объем рассчитанных:",
            "Объем не рассчитанных:", "№"
        ]
        
        static let servicePatterns = [
            #"^\d+\s+\d+\s+of\s+\d+$"#,  // "Page X of Y"
            #"^Generated:\s+"#
        ]
    }
    
    func parse(content: String) throws -> [IncomeEntry] {
        let pageItems = extractItemsFromPageText(pageText: content)
        
        return pageItems.sorted { $0.date > $1.date }
    }

}

extension PDFParser {
    // MARK: - Private Methods
    /// Извлекает элементы из текста страницы PDF
    private func extractItemsFromPageText(pageText: String) -> [IncomeEntry] {
        let lines = pageText.components(separatedBy: .newlines)
        
        return lines.compactMap { line in
            let cleanLine = line.trimmingCharacters(in: .whitespaces)
            
            guard !cleanLine.isEmpty, !isServiceLine(cleanLine) else { 
                return nil 
            }
            
            return parseDataLine(cleanLine)
        }
    }
    
    /// Проверяет, является ли строка служебной
    private func isServiceLine(_ line: String) -> Bool {
        // Проверяем префиксы
        if ParsingConfig.servicePrefixes.contains(where: { line.contains($0) }) {
            return true
        }
        
        // Проверяем локализованные заголовки
        let localizedHeaders = ["date", "make", "price", "status_pay", "source"]
            .compactMap { $0.localized }
        
        if localizedHeaders.contains(where: { line.contains($0) }) {
            return true
        }
        
        // Проверяем паттерны
        return ParsingConfig.servicePatterns.contains { pattern in
            line.range(of: pattern, options: .regularExpression) != nil
        }
    }
    
    /// Единый метод парсинга строки данных
    private func parseDataLine(_ line: String) -> IncomeEntry? {
        // Извлекаем дату
        guard let date = extractDate(from: line) else { return nil }
        
        // Извлекаем цену
        guard let price = extractPrice(from: line) else { return nil }
        
        // Извлекаем статус оплаты
        let isPaid = extractPaymentStatus(from: line)
        
        // Извлекаем марку и источник
        let (jobTitle, source) = extractMakeAndSource(from: line, 
                                                  excludingDate: true, 
                                                  excludingPrice: true)
        let jobDescription = exractJobDescription(from: line)
        
        guard !jobTitle.isEmpty else { return nil }
        
        return IncomeEntry(
            date: date,
            jobTitle: jobTitle, 
            jobDescription: jobDescription,
            price: price,
            isPaid: isPaid,
            source: source
        )
    }
    
    /// Извлекает дату из строки
    private func extractDate(from line: String) -> Date? {
        guard let range = line.range(of: ParsingConfig.datePattern, 
                                    options: .regularExpression) else {
            return nil
        }
        
        let dateString = String(line[range])
        return parseDateFromString(dateString)
    }
    
    /// Извлекает цену из строки
    private func extractPrice(from line: String) -> Double? {
        let priceRanges = line.ranges(of: ParsingConfig.pricePattern, 
                                     options: .regularExpression)
        
        // Берем второе число как цену (первое обычно номер строки)
        guard priceRanges.count >= 2 else { return nil }
        
        let priceString = String(line[priceRanges[1]])
        return Double(priceString)
    }
    
    /// Извлекает статус оплаты из строки
    private func extractPaymentStatus(from line: String) -> Bool {
        return line.contains("paid_for_cell".localized)
    }
    //TODO: написать функцию
    private func exractJobDescription(from line: String) -> String? {
        return ""
    }
    
    /// Извлекает марку и источник из строки
    private func extractMakeAndSource(from line: String, 
                                     excludingDate: Bool = true,
                                     excludingPrice: Bool = true) -> (make: String, source: IncomeSource) {
        var cleanLine = line
        
        // Удаляем дату если нужно
        if excludingDate {
            cleanLine = cleanLine.replacingOccurrences(
                of: ParsingConfig.datePattern, 
                with: "", 
                options: .regularExpression
            )
        }
        
        // Удаляем цену если нужно
        if excludingPrice {
            cleanLine = cleanLine.replacingOccurrences(
                of: ParsingConfig.pricePattern, 
                with: "", 
                options: .regularExpression
            )
        }
        
        // Удаляем статусы оплаты
        cleanLine = cleanLine.replacingOccurrences(of: "paid_for_cell".localized, with: "")
        cleanLine = cleanLine.replacingOccurrences(of: "unPaid_for_cell".localized, with: "")
        
        // Извлекаем компоненты
        let components = cleanLine.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty && Int($0) == nil } // Убираем числа и пустые строки
        
        guard !components.isEmpty else { 
            return ("", .mainJob) 
        }
        var sideJobs: [SideJob]?
        Task {
            sideJobs = try? await sideJobsManager.getAllJobs()
        }
        let jobs = sideJobs ?? []
        let make = components[0]
        let sourceString = components.dropFirst().joined(separator: " ")
        let source = IncomeSourceParser.fromDisplayName(sourceString, allJobs: jobs)
        
        return (make, source)
    }
    
    
    
    /// Парсит дату из строки
    private func parseDateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ParsingConfig.dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)
    }
}
