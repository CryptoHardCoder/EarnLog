//
//  CSVLoader.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//
import Foundation

final class CSVLoader: FileLoader {

    private let csvParser: FileParser
    
    init(csvParser: FileParser) {
        self.csvParser = csvParser
    }
    
    func load(from path: StorageLocation) async throws -> [IncomeEntry] {
        let url = try? await path.fileURL()
        guard let url = url else { throw FileHandlerError.invalidPath}
        do {
            let csvContent = try String(contentsOf: url, encoding: .utf8)
//            print(csvContent)
            let result = csvParser.parse(content: csvContent)
            return result
        } catch {
            print("❌ Ошибка чтения CSV файла \(url): \(error)")
            throw FileHandlerError.encodingFailed
        }
    }
    
    
}
