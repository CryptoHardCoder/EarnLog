//
//  CSVParser.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//
import Foundation

final class CSVParser: FileParser {
    
    private let sideJobManager: SideJobManagerRepository
    
    init(sideJobManager: SideJobManagerRepository) {
        self.sideJobManager = sideJobManager
    }
    
    func parse(content: String) throws -> [IncomeEntry]{
        try parseCSVToItems(csvContent: content)
    }
    
    //TODO: - поправить парсинг линий, сейчас конечные строки где пишется итоги по нулям подтягиваются. Надо чтобы эти строки игнорировались при парсинге
    /// Парсит CSV контент в массив товаров
    private func parseCSVToItems(csvContent: String) throws -> [IncomeEntry] {
        let lines = csvContent.components(separatedBy: .newlines)
//        print(lines)
        var items: [IncomeEntry] = []
        
        // Пропускаем заголовок (первая строка)
        for line in lines.dropFirst() {
//            print("line: \(line)")
            
            // Пропускаем пустые строки
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            // Дополнительная проверка на заголовок (проверяем первое поле)
            var fields = parseCSVLine(line)
            print(fields)
            fields.removeAll { $0 == "" }
            print(fields)
//            print(type(of: fields))
            if !fields.isEmpty && fields[0] == "№"{
//               print("⚠️ Пропускаем строку заголовка: \(fields[0])")
               continue
            }
            if fields[0] == "total_count".localized ||
               fields[0] == "total_volume".localized ||
               fields[0] == "paid_volume".localized ||
               fields[0] == "unPaid_volume".localized{
               print("⚠️ Пропускаем строку заголовка: \(fields[0])")
               continue
            }
            // Изменено с >= 6 на >= 5, так как в CSV 5 полей: Дата,Марка,Цена,Статус оплаты,Место
            guard fields.count >= 6 else { 
                print("⚠️ Недостаточно полей в строке: \(fields.count), ожидается минимум 6")
                continue 
            }
            
//            print("fields: \(fields)")
            
            // Парсим поля: Дата,Марка,Цена,Статус оплаты,Место
            let dateString = fields[1].trimmingCharacters(in: .whitespaces)
//            print("dateString: \(dateString)")
            
            let jobTitle = fields[2].trimmingCharacters(in: .whitespaces)
//            print("make: \(make)")
            let jobDescription = " Написать функцию парсинга jobDescription"
            
            let priceString = fields[3].trimmingCharacters(in: .whitespaces)
            let price = Double(priceString) ?? 0.0
//            print("price: \(price)")
            
            let statusPaid = fields[4].trimmingCharacters(in: .whitespaces)
//            print("statusPaid: \(statusPaid)")
            
            let statusPaidBool: Bool
            if statusPaid == "paid_for_cell".localized {
                statusPaidBool = true
            } else {
                statusPaidBool = false
            }
//            print("statusPaidBool: \(statusPaidBool)")
            var sideJobs: [SideJob]? 
            Task{
                sideJobs = try? await sideJobManager.getAllJobs()
            }
            guard let jobs = sideJobs else { throw SideJobError.loadingFailed }
            let incomeSource: IncomeSource
            if fields.indices.contains(5) {
                let sourceString = fields[5].trimmingCharacters(in: .whitespaces)
                incomeSource = IncomeSourceParser.fromDisplayName(sourceString, allJobs: jobs)
            } else {
                incomeSource = IncomeSource.mainJob
            }
//            print("incomeSource: \(incomeSource)")
            
            // Создаем дату из строки даты
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Для стабильного парсинга
            
            let date = dateFormatter.date(from: dateString) ?? Date()
//            print("parsed date: \(date)")
            
            let item = IncomeEntry(
                date: date,
                jobTitle: jobTitle,
                jobDescription: jobDescription,
                price: price,
                isPaid: statusPaidBool,
                source: incomeSource
            )
            
            items.append(item)
//            print("✅ Добавлен товар: \(item)")
        }
        
//        print("✅ Загружено \(items.count) товаров из CSV")
        return items
    }
    
    /// Парсит строку CSV с учетом экранированных полей
    private func parseCSVLine(_ line: String) -> [String] {
    var fields: [String] = []
    var currentField = ""
    var inQuotes = false
    var i = line.startIndex
    
    while i < line.endIndex {
        let char = line[i]
        
        if char == "\"" {
            if inQuotes && i < line.index(before: line.endIndex) && line[line.index(after: i)] == "\"" {
                // Двойная кавычка внутри поля
                currentField += "\""
                i = line.index(after: i) // Пропускаем следующую кавычку
            } else {
                // Начало или конец экранированного поля
                inQuotes.toggle()
            }
        } else if char == "," && !inQuotes {
            // Разделитель поля
            fields.append(currentField)
            currentField = ""
        } else {
            currentField += String(char)
        }
        
        i = line.index(after: i)
    }
    
    // Добавляем последнее поле
    fields.append(currentField)
    
    return fields
}
    
    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escapedField = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escapedField)\""
        }
        return "\"\(field)\""
    }
    
}
