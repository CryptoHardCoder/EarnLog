//
//  ArchiveManager.swift
//  JobData
//
//  Created by M3 pro on 26/07/2025.
//
import UIKit
import PDFKit

// MARK: - Расширение AppFileManager для CSV архивации
class ArchiveManager: MemoryTrackable {
    
    private let fileManager = FileManager.default
    
    // MARK: - Константы для файлов
    private lazy var csvArchivesFolderURL = appPaths.operationFolder(for: .archive)
    
    private lazy var forRecoveryArchivesFolderURL = appPaths.backupFolder(for: .archive)
    
    private lazy var lastKnownDateFileURL = 
        appPaths.myApplicationSupportFilesFolderURL.appending(path: lastKnownDateFileName)
    
    private lazy var archiveMetadataFileURL = 
        appPaths.myApplicationSupportFilesFolderURL.appending(path: archiveMetadataFileName)
    
    
    private var allItems: [IncomeEntry] {
        dataProvider.getAllItems()
    }
        
    private var lastKnownDateFileName = "Last Known Date.json"
    
    private var archiveMetadataFileName = "Archive Metadata.json"
    
    private let dataProvider: DataProvider
    private let appPaths: AppPaths
    private let dataService: UniversalDataService
    
    init(fileManager: DataProvider, appPaths: AppPaths, dataService: UniversalDataService) {
        self.dataProvider = fileManager
        self.appPaths = appPaths
        self.dataService = dataService
        trackCreation()
    }
    
    /// Создает папку для CSV архивов если её нет
    private func ensureCSVArchivesFolderExists(existURL: URL ) {
        
        if !fileManager.fileExists(atPath: existURL.path) {
            do {
                try fileManager.createDirectory(at: existURL, withIntermediateDirectories: true)
                print("📁 Создана папка для CSV архивов: \(csvArchivesFolderURL.path)")
            } catch {
                print("❌ Ошибка создания папки архивов: \(error)")
            }
        }
    }
    
     func getExistingArchiveFiles() -> [String] {
         ensureCSVArchivesFolderExists(existURL: csvArchivesFolderURL)
         
         let metadata = loadArchiveMetadata()
         let filesFromMetadata: [String] = metadata.map { $0.fileName }
         var fileNamesToReturn = [String]()
         
         do {
             let filesInDirectory = try fileManager.contentsOfDirectory(atPath: csvArchivesFolderURL.path)
             
             for fileName in filesFromMetadata {
                 if filesInDirectory.contains(fileName) {
                     fileNamesToReturn.append(fileName)
                 } else {
                     print("⚠️ Файл из метаданных не найден в папке: \(fileName)")
                 }
             }
             
             let extraFiles = Set(filesInDirectory).subtracting(Set(filesFromMetadata))
             if !extraFiles.isEmpty {
                 print("⚠️ Найдены файлы без метаданных: \(extraFiles)")
             }
             
         } catch {
             print("❌ Ошибка чтения содержимого папки архивов: \(error)")
         }
         
         return fileNamesToReturn
     }

     func cleanupArchiveInconsistencies() {
         let metadata = loadArchiveMetadata()
         var validMetadata = [ArchiveMetadata]()
         
         do {
             let filesInDirectory = try fileManager.contentsOfDirectory(atPath: csvArchivesFolderURL.path)
             
             for meta in metadata {
                 if filesInDirectory.contains(meta.fileName) {
                     validMetadata.append(meta)
                 } else {
                     print("🧹 Удаляем метаданные для несуществующего файла: \(meta.fileName)")
                 }
             }
             
             // Сохраняем очищенные метаданные
             if validMetadata.count != metadata.count {
                 let data = try JSONEncoder().encode(validMetadata)
                 try data.write(to: archiveMetadataFileURL)
                 print("✅ Метаданные очищены от несуществующих файлов")
             }
             
         } catch {
             print("❌ Ошибка при очистке несогласованностей: \(error)")
         }
     }

    private func saveLastKnownDate(_ date: Date) {
        let calendar = Calendar.current
        let dateComponents = DateComponents(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date)
        )

        // Папка для файлов
        let folderURL = appPaths.myApplicationSupportFilesFolderURL
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
                print("📁 Папка Application Support создана: \(folderURL.path)")
            } catch {
                print("❌ Ошибка создания папки Application Support: \(error)")
            }
        }

        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: lastKnownDateFileURL.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                // Это директория - удаляем её
                do {
                    try fileManager.removeItem(at: lastKnownDateFileURL)
                    print("🗑 Удалена старая директория с именем файла")
                } catch {
                    print("❌ Не удалось удалить старую директорию: \(error)")
                    return
                }
            }
            // Если это файл - ничего не делаем, просто перезаписываем
        }

        // Сохраняем файл
        do {
            let data = try JSONEncoder().encode(dateComponents)
            try data.write(to: lastKnownDateFileURL)
            
            if !fileManager.fileExists(atPath: lastKnownDateFileURL.path) {
                print("✅ Файл последней даты создан")
            }
            // Убираем постоянное логирование при обычном обновлении
        } catch {
            print("❌ Ошибка сохранения последней даты: \(error)")
        }
    }
    
    private func loadLastKnownDate() -> DateComponents? {
        do {
            let data = try Data(contentsOf: lastKnownDateFileURL)
            return try JSONDecoder().decode(DateComponents.self, from: data)
        } catch {
            return nil
        }
    }
    
    // MARK: - Главная функция проверки архивации
    func checkArchiveOnAppStart() {
        let calendar = Calendar.current
        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        guard let lastKnownComponents = loadLastKnownDate() else {
//            print("🚀 Первый запуск приложения - сохраняем текущую дату")
            saveLastKnownDate(today)
            return
        }
        
//        print("📅 Последний запуск: \(lastKnownComponents.month ?? 0).\(lastKnownComponents.year ?? 0)")
//        print("📅 Сегодня: \(todayComponents.month ?? 0).\(todayComponents.year ?? 0)")
        
        let isNewMonth = (todayComponents.year != lastKnownComponents.year) ||
                        (todayComponents.month != lastKnownComponents.month)
        
        if isNewMonth && allItems.isEmpty {
            
            archiveCurrentDataToCSV(
                for: lastKnownComponents.year ?? 0,
                month: lastKnownComponents.month ?? 0
            )
        } else if isNewMonth {
//            print("🗓️ Новый месяц, но нет данных для архивации")
        } else {
//            print("📅 Тот же месяц - архивация не требуется")
        }
        
        saveLastKnownDate(today)
    }
    
    
    // Архивация данных
    func archiveData<T: Exportable>(_ items: [T], format: FileFormat, period: TimeFilter) -> URL? {
        let config = FileProcessingConfiguration.defaultArchive
        let context = DataProcessingContext(items: items, configuration: config, period: period)
        
        let result = dataService.processData(context: context, to: format)
        
        switch result {
        case .success(let url):
            print("✅ Архивация успешна: \(url)")
            return url
        case .failure(let error):
            print("❌ Ошибка архивации: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Процесс архивации в CSV
    // TODO: - Сделать чтения формата из выбора пользователя и передать внутри в тело функции чтобы автоматом выбрался формат файла
    /// Архивирует текущие данные в CSV файл в фоновом потоке
    func archiveCurrentDataToCSV(for year: Int, month: Int) {
        // Запускаем архивацию в фоновом потоке
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            
            // Создаем копию данных для безопасной работы в фоне
            let itemsToArchive = allItems.filter { item in
                let calendar = Calendar.current
                let itemMonth = calendar.component(.month, from: item.date)
                let itemYear = calendar.component(.year, from: item.date)
                return month == itemMonth && year == itemYear
            }
            
            guard !itemsToArchive.isEmpty else {
                print("⚠️ Нет данных для архивации за \(month)/\(year)")
                return
            }
            
            let itemsCount = itemsToArchive.count
            print("📦 Архивируем \(itemsCount) записей за \(month)/\(year)...")
            
            // Создаем конфигурацию для архивации
            let config = FileProcessingConfiguration.defaultArchive
            
            // Создаем фильтр времени для архивного периода
            let calendar = Calendar.current
            var startComponents = DateComponents()
            startComponents.year = year
            startComponents.month = month
            startComponents.day = 1
            
            var endComponents = DateComponents()
            endComponents.year = year
            endComponents.month = month
            endComponents.day = calendar.range(of: .day, in: .month, for: calendar.date(from: startComponents) ?? Date())?.upperBound ?? 31
            
            guard let _ = calendar.date(from: startComponents),
                  let _ = calendar.date(from: endComponents) else {
                print("❌ Ошибка создания дат для архивации")
                return
            }
            
            let timeFilter = TimeFilter.month
            
            // Создаем контекст обработки данных
            let context = DataProcessingContext(
                items: itemsToArchive,
                configuration: config,
                period: timeFilter
            )
            
            // Используем универсальный сервис для создания архива
            let result = self.dataService.processData(context: context, to: .csv)
            
            switch result {
            case .success(let fileURL):
                print("✅ CSV архив успешно создан: \(fileURL.path)")
                
                // Создаем метаданные архива
                let fileName = fileURL.lastPathComponent
                let metadata = ArchiveMetadata(
                    year: year,
                    month: month,
                    itemsCount: itemsCount,
                    fileName: fileName,
                    createdAt: Date()
                )
                self.saveArchiveMetadata(metadata)
//                // Сохраняем метаданные на главном потоке
//                DispatchQueue.main.async {
//                    
//                }
                
            case .failure(let error):
                // Обработка ошибок на главном потоке
                DispatchQueue.main.async {
                    print("❌ Ошибка сохранения CSV архива: \(error.localizedDescription)")
                    // TODO: Сделать вью для создания архива вручную
                    // Здесь можно добавить уведомление пользователя об ошибке
                }
            }
        }
    }
    
//    // MARK: - Процесс архивации в CSV
//    
//    /// Архивирует текущие данные в CSV файл в фоновом потоке
//    func archiveCurrentDataToCSV(for year: Int, month: Int) {
////        let userFormat = UserDefaults.standard.string(forKey: userFormatKey) ?? FileFormat.pdf.rawValue
////        
////        let format = FileFormat(rawValue: userFormat)
//        
//        // Запускаем архивацию в фоновом потоке
//        DispatchQueue.global(qos: .utility).async { [weak self] in
//            guard let self = self else { return }
//            
////            print("📦 Начинаем архивацию в фоновом потоке за \(month)/\(year)")
//        
//        // Убеждаемся что папка существует
//        self.ensureCSVArchivesFolderExists(existURL: csvArchivesFolderURL)
//        self.ensureCSVArchivesFolderExists(existURL: forRecoveryArchivesFolderURL)
//        
//        let fileName = "archive_\(month)_\(year).csv"
//        let fileURL = self.csvArchivesFolderURL.appendingPathComponent(fileName)
//        let fileForRecoveryURL = self.forRecoveryArchivesFolderURL.appendingPathComponent(fileName)
//        
//        // Создаем копию данных для безопасной работы в фоне
//            let itemsToArchive = AppFileManager.shared.allItems.filter { item in
//            let calendar = Calendar.current
//            let itemMonth = calendar.component(.month, from: item.date)
//            let itemYear  = calendar.component(.year, from: item.date)
//            return month == itemMonth && year == itemYear
//        }
//        let itemsCount = itemsToArchive.count
//        
////        print("📦 Архивируем \(itemsCount) записей...")
//            let titleForFile = "\("title_for_archive_file".localized ) \(month).\(year)"
//        // Создаем CSV контент в фоне
//            let csvContent = createCSVContent(from: itemsToArchive, title: titleForFile, )
//        
//        do {
//            // Сохраняем CSV файл
//            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
//            try fileManager.copyItem(at: fileURL, to: fileForRecoveryURL)
////            print("💾 CSV архив сохранен в фоне: \(csvFileName)")
//            // Создаем метаданные архива
//           let metadata = ArchiveMetadata(
//                year: year,
//                month: month,
//                itemsCount: itemsCount,
//                csvFileName: fileName,
//                createdAt: Date()
//            )
//            self.saveArchiveMetadata(metadata)
//            
//        } catch {
//            //TODO: Сделать вью для создания архива вручную 
//            // Обработка ошибок на главном потоке
//            DispatchQueue.main.async {
//                print("❌ Ошибка сохранения CSV архива: \(error)")
//                // Здесь можно добавить уведомление пользователя об ошибке
//                }
//            }
//        }
//    }
    
    
    // MARK: - Работа с метаданными архивов
    
    /// Сохраняет метаданные архива
    private func saveArchiveMetadata(_ metadata: ArchiveMetadata) {
        var allMetadata = loadArchiveMetadata()
        print(allMetadata)
        
        // Удаляем существующие метаданные за этот же месяц/год
        allMetadata.removeAll { existingMetadata in
            existingMetadata.year == metadata.year && existingMetadata.month == metadata.month
        }
        
        // Добавляем новые метаданные
        allMetadata.append(metadata)
        
        // Сортируем по убыванию (новые первыми)
        allMetadata.sort { first, second in
            if first.year != second.year {
                return first.year > second.year
            }
            return first.month > second.month
        }
        
        do {
            let data = try JSONEncoder().encode(allMetadata)
            try data.write(to: archiveMetadataFileURL)
//            print("💾 Метаданные архива сохранены")
        } catch {
            print("❌ Ошибка сохранения метаданных: \(error)")
        }
    }
    /// Загружает товары из CSV файла
    func loadItemsFromCSV(fileName: String) -> [IncomeEntry] {
        let csvFileURL = csvArchivesFolderURL.appendingPathComponent(fileName)
//        print(csvFileURL)
        
        do {
            let csvContent = try String(contentsOf: csvFileURL, encoding: .utf8)
//            print(csvContent)
            return parseCSVToItems(csvContent)
        } catch {
            print("❌ Ошибка чтения CSV файла \(fileName): \(error)")
            return []
        }
    }
    
    //TODO: - поправить парсинг линий, сейчас конечные строки где пишется итоги по нулям подтягиваются. Надо чтобы эти строки игнорировались при парсинге
    /// Парсит CSV контент в массив товаров
    private func parseCSVToItems(_ csvContent: String) -> [IncomeEntry] {
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
            
            let make = fields[2].trimmingCharacters(in: .whitespaces)
//            print("make: \(make)")
            
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
            
            let incomeSource: IncomeSource
            if fields.indices.contains(5) {
                let sourceString = fields[5].trimmingCharacters(in: .whitespaces)
                incomeSource = IncomeSource.fromDisplayName(sourceString)
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
                car: make,
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
    /// Загружает метаданные всех архивов
    func loadArchiveMetadata() -> [ArchiveMetadata] {
        do {
            let data = try Data(contentsOf: archiveMetadataFileURL)
            return try JSONDecoder().decode([ArchiveMetadata].self, from: data)
        } catch {
            print("📂 Файл метаданных не найден или пуст")
            ensureCSVArchivesFolderExists(existURL: archiveMetadataFileURL)
            return []
        }
    }
    
    /// Получает список всех доступных месяцев
    func getAvailableMonths() -> [(year: Int, month: Int, displayName: String)] {
        var months: [(year: Int, month: Int, displayName: String)] = []
        
        // Добавляем текущий месяц если есть данные
        if !allItems.isEmpty {
            let calendar = Calendar.current
            let now = Date()
            let currentMonth = calendar.component(.month, from: now)
            let currentYear = calendar.component(.year, from: now)
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "MMMM yyyy"
            let displayName = dateFormatter.string(from: now)
            
            months.append((currentYear, currentMonth, displayName))
        }
        
        // Добавляем архивированные месяцы из метаданных
        let metadata = loadArchiveMetadata()
        for archiveMetadata in metadata {
            months.append(
                (
                    archiveMetadata.year, 
                    archiveMetadata.month, 
                    archiveMetadata.monthDisplayName(Locale(identifier: "locale".localized))
                )
            )
        }
        
        // Убираем дубликаты и сортируем
        let uniqueKeys = Set(months.map { "\($0.year)-\($0.month)" })
        let uniqueMonths = uniqueKeys.compactMap { key -> (year: Int, month: Int, displayName: String)? in
            return months.first { "\($0.year)-\($0.month)" == key }
        }
        
        let sortedMonths = uniqueMonths.sorted { first, second in
            if first.year != second.year {
                return first.year > second.year
            }
            return first.month > second.month
        }
        
//        print("📊 Найдено месяцев для отображения: \(sortedMonths.count)")
        return sortedMonths
    }
    
    // MARK: - Получение информации об архивах
    
    /// Получает информацию о всех CSV архивах
    func getArchiveInfo() -> [(displayName: String, itemsCount: Int, filePath: String, createdAt: Date)] {
        let metadata = loadArchiveMetadata()
        
        return metadata.map { meta in
            let filePath = csvArchivesFolderURL.appendingPathComponent(meta.fileName).path
            return (meta.monthDisplayName(Locale(identifier: "locale".localized)), meta.itemsCount, filePath, meta.createdAt)
        }
    }
    
    deinit {
        trackDeallocation() // для анализа на memory leaks
    }
}

// MARK: - PDF Archive Functions
extension ArchiveManager {
    
    /// Загружает данные из PDF архива
    func loadItemsFromPDF(fileName: String) -> [IncomeEntry] {
        let pdfFileURL = csvArchivesFolderURL.appendingPathComponent(fileName)
        
        guard let pdfDocument = PDFDocument(url: pdfFileURL) else {
            print("❌ Не удалось открыть PDF файл: \(fileName)")
            return []
        }
        
        return parsePDFToItems(pdfDocument)
    }
    
    /// Парсит PDF документ в массив IncomeEntry
    private func parsePDFToItems(_ pdfDocument: PDFDocument) -> [IncomeEntry] {
        var items: [IncomeEntry] = []
        let pageCount = pdfDocument.pageCount
        
        for pageIndex in 0..<pageCount {
            guard let page = pdfDocument.page(at: pageIndex),
                  let pageText = page.string else { continue }
            
            let pageItems = extractItemsFromPageText(pageText)
            items.append(contentsOf: pageItems)
        }
        
        print("✅ Загружено \(items.count) записей из PDF")
        return items.sorted { $0.date > $1.date } // Сортируем по убыванию даты
    }
    
    /// Извлекает элементы из текста страницы PDF
    private func extractItemsFromPageText(_ pageText: String) -> [IncomeEntry] {
        var items: [IncomeEntry] = []
        let lines = pageText.components(separatedBy: .newlines)
        
        // Ищем строки с данными (пропускаем заголовки, итоги и служебную информацию)
        for line in lines {
            let cleanLine = line.trimmingCharacters(in: .whitespaces)
            
            // Пропускаем пустые строки, заголовки и служебную информацию
            guard !cleanLine.isEmpty,
                  !isServiceLine(cleanLine),
                  let item = parseDataLineFromPDF(cleanLine) else { continue }
            
            items.append(item)
        }
        
        return items
    }
    
    /// Проверяет, является ли строка служебной (заголовок, итоги, метаданные)
    private func isServiceLine(_ line: String) -> Bool {
        let servicePrefixes = [
            "iTracker", "Archived Data", "Exported Data", "Page", "Generated:",
            "Итоги:", "Общее количество:", "Общий объем:", "Объем рассчитанных:",
            "Объем не рассчитанных:", "№", "date".localized, "make".localized,
            "price".localized, "status_pay".localized, "source".localized
        ]
        
        return servicePrefixes.contains { line.contains($0) } || 
               line.matches(#"^\d+\s+\d+\s+of\s+\d+$"#) || // "Page X of Y"
               line.matches(#"^Generated:\s+"#)
    }
    
    /// Парсит строку данных из PDF в IncomeEntry
    private func parseDataLineFromPDF(_ line: String) -> IncomeEntry? {
        // PDF текст может быть отформатирован по-разному
        // Попробуем несколько стратегий парсинга
        
        // Стратегия 1: Разделение по пробелам с учетом структуры таблицы
        if let item = parseTableFormatLine(line) {
            return item
        }
        
        // Стратегия 2: Поиск паттернов в тексте
        if let item = parsePatternBasedLine(line) {
            return item
        }
        
        return nil
    }
    
    /// Парсит строку в табличном формате: № Дата Марка Цена Статус Источник
    private func parseTableFormatLine(_ line: String) -> IncomeEntry? {
        let components = line.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        // Минимум 6 компонентов: номер, дата, марка, цена, статус, источник
        guard components.count >= 6 else { return nil }
        
        // Первый элемент должен быть числом (номер строки)
        guard Int(components[0]) != nil else { return nil }
        
        // Парсим дату (второй элемент)
        let dateString = components[1]
        guard let date = parseDateFromString(dateString) else { return nil }
        
        // Парсим остальные поля
        let make = components[2]
        
        guard let price = Double(components[3]) else { return nil }
        
        let statusString = components[4]
        let isPaid = (statusString == "paid_for_cell".localized)
        
        // Источник может содержать пробелы, объединяем оставшиеся компоненты
        let sourceString = components.dropFirst(5).joined(separator: " ")
        let source = IncomeSource.fromDisplayName(sourceString)
        
        return IncomeEntry(
            date: date,
            car: make,
            price: price,
            isPaid: isPaid,
            source: source
        )
    }
    
    /// Парсит строку используя регулярные выражения для поиска паттернов
    private func parsePatternBasedLine(_ line: String) -> IncomeEntry? {
        // Паттерн для поиска даты в формате dd.MM.yyyy
        let datePattern = #"(\d{2}\.\d{2}\.\d{4})"#
        guard let dateMatch = line.range(of: datePattern, options: .regularExpression) else {
            return nil
        }
        
        let dateString = String(line[dateMatch])
        guard let date = parseDateFromString(dateString) else { return nil }
        
        // Паттерн для поиска цены (число с возможной десятичной частью)
        let pricePattern = #"(\d+(?:\.\d{2})?)"#
        let priceMatches = line.ranges(of: pricePattern, options: .regularExpression)
        
        // Ищем цену (обычно не первое число, так как первое - номер строки)
        guard priceMatches.count >= 2 else { return nil }
        let priceRange = priceMatches[1] // Берем второе число как цену
        let priceString = String(line[priceRange])
        guard let price = Double(priceString) else { return nil }
        
        // Ищем статус оплаты
        let paidStatus = line.contains("paid_for_cell".localized)
        
        // Для марки и источника используем простую эвристику
        // Удаляем известные элементы и пытаемся выделить марку и источник
        var remainingLine = line
        remainingLine = remainingLine.replacingOccurrences(of: dateString, with: "")
        remainingLine = remainingLine.replacingOccurrences(of: priceString, with: "")
        remainingLine = remainingLine.replacingOccurrences(of: "paid_for_cell".localized, with: "")
        remainingLine = remainingLine.replacingOccurrences(of: "unPaid_for_cell".localized, with: "")
        
        let remainingComponents = remainingLine.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty && Int($0) == nil } // Убираем числа и пустые строки
        
        guard remainingComponents.count >= 2 else { return nil }
        
        let make = remainingComponents[0]
        let sourceString = remainingComponents.dropFirst().joined(separator: " ")
        let source = IncomeSource.fromDisplayName(sourceString)
        
        return IncomeEntry(
            date: date,
            car: make,
            price: price,
            isPaid: paidStatus,
            source: source
        )
    }
    
    /// Парсит дату из строки
    private func parseDateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)
    }
    
    /// Обновленная версия getItemsForMonth с поддержкой PDF
    func getItemsForMonthPDF(year: Int, month: Int) -> [IncomeEntry] {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        let metadata = loadArchiveMetadata()
        let targetMetadata = metadata.first(where: { $0.year == year && $0.month == month })

        // Фильтруем данные из памяти
        let dataFromMemory = allItems.filter {
            calendar.component(.year, from: $0.date) == year &&
            calendar.component(.month, from: $0.date) == month
        }

        var result: [IncomeEntry] = []

        if year == currentYear && month == currentMonth {
            // Текущий месяц: добавляем из памяти
            result.append(contentsOf: dataFromMemory)
        }

        // Если нашли метаданные архива, подгружаем из PDF
        if let targetMetadata = targetMetadata {
            let fileName = targetMetadata.fileName
            
            if fileName.hasSuffix(".pdf") {
                let dataFromFile = loadItemsFromPDF(fileName: fileName)
                result.append(contentsOf: dataFromFile)
            } else if fileName.hasSuffix(".csv") {
                // Обратная совместимость с CSV архивами
                let dataFromFile = loadItemsFromCSV(fileName: fileName)
                result.append(contentsOf: dataFromFile)
            }
        } else {
            print("❌ Архив за \(month).\(year) не найден")
        }

        // Убираем дубликаты
        let uniqueItems = Array(Set(result))
        return uniqueItems.sorted { $0.date > $1.date }
    }
}

