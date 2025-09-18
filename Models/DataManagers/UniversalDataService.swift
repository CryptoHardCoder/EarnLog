//
//  UniversalDataService.swift
//  EarnLog
//
//  Created by M3 pro on 28/08/2025.
import Foundation
import UIKit
import PDFKit

// MARK: - Универсальный сервис обработки данных
class UniversalDataService {
    private let fileManager = FileManager.default
    private var currentOperation: DataOperation = .export
    private let appFileManager: AppFileManager
    private let appPaths: AppPaths  
    // Инициализация с базовым путем
    init(appFileManager: AppFileManager, appPaths: AppPaths){
        self.appFileManager = appFileManager
        self.appPaths = appPaths
        
    }
    
    // Получение папок для текущей операции
    private func getFolders(for operation: DataOperation) -> (main: URL, backup: URL) {
//        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let mainFolder = appFileManager.userAccessibleFolder.appendingPathComponent(operation.folderName)
//        let backupFolder = appFileManager.myApplicationSupportFilesFolderURL.appendingPathComponent(
//            operation.backupFolderName)
        let mainFolder = appPaths.operationFolder(for: operation)
        let backupFolder = appPaths.backupFolder(for: operation)
        return (mainFolder, backupFolder)
    }
    
    // MARK: - Главный метод обработки данных
    func processData<T: Exportable>(
        context: DataProcessingContext<T>,
        to format: FileFormat
    ) -> Result<URL, DataProcessingError> {
        
        guard !context.items.isEmpty else {
            return .failure(.noData)
        }
        
        self.currentOperation = context.configuration.operation
        let folders = getFolders(for: currentOperation)
        
        guard createDirectoriesIfNeeded(main: folders.main, backup: folders.backup) else {
            return .failure(.directoryCreationFailed)
        }
        
        switch format {
        case .csv:
            return processToCSV(context: context, folders: folders)
        case .pdf:
            return processToPDF(context: context, folders: folders)
        }
    }

    // MARK: - Обработка в CSV
    private func processToCSV<T: Exportable>(
        context: DataProcessingContext<T>, 
        folders: (main: URL, backup: URL)
    ) -> Result<URL, DataProcessingError> {
        let fileName = "\(context.fileName).csv"
        let mainURL = folders.main.appendingPathComponent(fileName)
        let backupURL = folders.backup.appendingPathComponent(fileName)
        
        let csvContent = createCSVContent(context: context)
        
        return writeFile(content: csvContent, to: mainURL, recoveryURL: backupURL)
    }
    
    // Создание содержимого CSV (остается тем же)
    private func createCSVContent<T: Exportable>(context: DataProcessingContext<T>) -> String {
        var content = "\(context.displayTitle)\n"
        
        let headers = ["№"] + (context.items.first?.csvHeaders ?? [])
        content += headers.map { escapeCSVField($0) }.joined(separator: ",") + "\n"
        
        for (index, item) in context.items.enumerated() {
            let rowNumber = String(index + 1)
            let row = [rowNumber] + item.csvRow
            content += row.map { escapeCSVField($0) }.joined(separator: ",") + "\n"
        }
        
        if context.configuration.includeTotal {
            content += createSummaryRows(for: context, headers: headers)
        }
        
        return content
    }
    
    // Остальные методы остаются теми же...
    private func createSummaryRows<T: Exportable>(for context: DataProcessingContext<T>, headers: [String]) -> String {
        // ... тот же код что и раньше
        let summary = context.summary
        var summaryContent = "\n"
        
        var emptyRow = Array(repeating: "", count: headers.count)
        
        emptyRow[0] = "total_count".localized
        if headers.count > 2 {
            emptyRow[1] = String(summary.totalCount)
        }
        summaryContent += emptyRow.map { escapeCSVField($0) }.joined(separator: ",") + "\n"
        
        emptyRow = Array(repeating: "", count: headers.count)
        emptyRow[0] = "total_volume".localized
        if headers.count > 2 {
            emptyRow[1] = String(format: "%.2f", summary.totalVolume)
        }
        summaryContent += emptyRow.map { escapeCSVField($0) }.joined(separator: ",") + "\n"
        
        emptyRow = Array(repeating: "", count: headers.count)
        emptyRow[0] = "paid_volume".localized
        if headers.count > 2 {
            emptyRow[1] = String(format: "%.2f", summary.paidVolume)
        }
        summaryContent += emptyRow.map { escapeCSVField($0) }.joined(separator: ",") + "\n"
        
        emptyRow = Array(repeating: "", count: headers.count)
        emptyRow[0] = "unPaid_volume".localized
        if headers.count > 2 {
            emptyRow[1] = String(format: "%.2f", summary.unpaidVolume)
        }
        summaryContent += emptyRow.map { escapeCSVField($0) }.joined(separator: ",") + "\n"
        
        return summaryContent
    }
    
    // MARK: - Обработка в PDF
    private func processToPDF<T: Exportable>(
        context: DataProcessingContext<T>, 
        folders: (main: URL, backup: URL)
    ) -> Result<URL, DataProcessingError> {
        let fileName = "\(context.fileName).pdf"
        let mainURL = folders.main.appendingPathComponent(fileName)
        
        let pdfCreator = PDFCreator(context: context) // Переименовали класс
        
        do {
            let pdfData = try pdfCreator.createPDF()
            try pdfData.write(to: mainURL)
            
            let operationType = context.configuration.operation == .export ? "экспортирован" : "архивирован"
            print("✅ PDF успешно \(operationType): \(mainURL.path)")
            return .success(mainURL)
        } catch {
            print("❌ Ошибка при создании PDF: \(error)")
            return .failure(.fileCreationFailed)
        }
    }
    
    // Остальные вспомогательные методы остаются теми же...
    private func createDirectoriesIfNeeded(main: URL, backup: URL) -> Bool {
        do {
            if !fileManager.fileExists(atPath: main.path) {
                try fileManager.createDirectory(at: main, withIntermediateDirectories: true)
            }
            if !fileManager.fileExists(atPath: backup.path) {
                try fileManager.createDirectory(at: backup, withIntermediateDirectories: true)
            }
            return true
        } catch {
            print("❌ Ошибка создания папки: \(error)")
            return false
        }
    }
    
    private func writeFile(content: String, to mainURL: URL, recoveryURL: URL) -> Result<URL, DataProcessingError> {
        do {
            [mainURL, recoveryURL].forEach { url in
                if fileManager.fileExists(atPath: url.path) {
                    try? fileManager.removeItem(at: url)
                }
            }
            
            try content.write(to: mainURL, atomically: true, encoding: .utf8)
            try fileManager.copyItem(at: mainURL, to: recoveryURL)
            
            let operationType = currentOperation == .export ? "экспортирован" : "архивирован"
            print("✅ Файл успешно \(operationType): \(mainURL.path)")
            return .success(mainURL)
        } catch {
            print("❌ Ошибка при записи файла: \(error)")
            return .failure(.fileCreationFailed)
        }
    }
    
    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escapedField = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escapedField)\""
        }
        return "\"\(field)\""
    }

    // Экспорт данных
    func exportData<T: Exportable>(_ items: [T], format: FileFormat, period: TimeFilter) -> URL? {
        let config = FileProcessingConfiguration.defaultExport
        let context = DataProcessingContext(items: items, configuration: config, period: period)
        
        let result = processData(context: context, to: format)
        
        switch result {
        case .success(let url):
            print("✅ Экспорт успешен: \(url)")
            return url
        case .failure(let error):
            print("❌ Ошибка экспорта: \(error.localizedDescription)")
            return nil
        }
    }
}

//// MARK: - Переименованный генератор PDF
//typealias PDFGenerator<T: Exportable> = PDFCreator<T>
//
//// Класс PDFCreator остается тем же, только контекст теперь DataProcessingContext
