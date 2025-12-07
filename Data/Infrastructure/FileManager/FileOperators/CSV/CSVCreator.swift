//
//  CSVCreator.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//

import Foundation

final class CSVCreator: FileDataCreator {

    func createData(context: DataProcessingContext) throws -> Data {
        return try createCSVContent(context: context)
    }

//    func create(context: DataProcessingContext, folders: (mainPath: String, backupPath: String)) -> Result<String, FileHandlerError> {
//        let result = processToCSV(context: context, folders: folders)
//        
//        switch result {
//            case .success(let successURL):
//                return .success(successURL)
//            case .failure(let failure):
//                return .failure(failure)
//        }
//    }
   
}

extension CSVCreator {
    // MARK: - Обработка в CSV
//    private func processToCSV(
//        context: DataProcessingContext, 
//        folders: (mainPath: String, backupPath: String)
//    ) -> Result<String, FileHandlerError> {
//        let fileName = "\(context.fileName).csv"
//        let mainURL = URL(filePath: folders.mainPath).appendingPathComponent(fileName)
//        let backupURL = URL(filePath: folders.backupPath).appendingPathComponent(fileName)
//        
//        let csvContent = createCSVContent(context: context)
//        
//        return writeFile(content: csvContent, to: mainURL.path, recoveryPath: backupURL.path)
//    }
    
    // Создание содержимого CSV (остается тем же)
    private func createCSVContent(context: DataProcessingContext) throws -> Data {
        var content = "\(context.displayTitle)\n"
        
        let headers = ["№"] + (context.columnHeaders)
        content += headers.map { escapeCSVField($0) }.joined(separator: ",") + "\n"
        
        for (index, item) in context.items.enumerated() {
            let rowNumber = String(index + 1)
            let row = [rowNumber] + context.stringsForRow(item: item)
            content += row.map { escapeCSVField($0) }.joined(separator: ",") + "\n"
        }
        
        if context.configuration.includeTotal {
            content += createSummaryRows(for: context, headers: headers)
        }
        guard let data = content.data(using: .utf8) else { throw FileHandlerError.contentCreationFailed }
        return data
    }
    
//    private func writeFile(content: String, to mainPath: String, recoveryPath: String) -> Result<String, FileHandlerError> {
//        do {
//            let mainURL = URL(filePath: mainPath)
//            let recoveryURL = URL(filePath: recoveryPath)
//            
//            [mainURL, recoveryURL].forEach { url in
//                if fileManager.fileExists(atPath: url.path) {
//                    try? fileManager.removeItem(at: url)
//                }
//            }
//            
//            try content.write(to: mainURL, atomically: true, encoding: .utf8)
//            try fileManager.copyItem(at: mainURL, to: recoveryURL)
//            
////            let operationType = currentOperation == .export ? "экспортирован" : "архивирован"
////            print("✅ Файл успешно \(operationType): \(mainURL.path)")
//            return .success(mainURL.path)
//        } catch {
//            print("❌ Ошибка при записи файла: \(error)")
//            return .failure(.fileCreationFailed)
//        }
//    }

    // Остальные методы остаются теми же...
    private func createSummaryRows(for context: DataProcessingContext, headers: [String]) -> String {
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

   
}
