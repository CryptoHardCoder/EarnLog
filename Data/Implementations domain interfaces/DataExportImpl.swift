//
//  UniversalDataService.swift
//  EarnLog
//
//  Created by M3 pro on 28/08/2025.
import Foundation

// MARK: - DataExportRepository implementation class
final class DataExportImpl: DataExportRepository {
    
    private let fileService: FileStorageService
    private var currentOperation: DataOperation = .export
    private let appPaths: LocalStoragePathBuilderImpl
    private let fileHandler: FileHandler
    // Инициализация с базовым путем
    init(fileService: FileStorageService, appPaths: LocalStoragePathBuilderImpl, fileHandler: FileHandler) {
        self.fileService = fileService
        self.appPaths = appPaths
        self.fileHandler = fileHandler
    }
    
    func exportData(items: [IncomeEntry]) async throws -> URL {
        let config = FileConfiguration.defaultExport
        let context = DataProcessingContext(items: items, configuration: config)
        
        self.currentOperation = context.configuration.operation
        let folderURL = try? await getExportFolder()
        
        guard let folder = folderURL else { throw FileHandlerError.directoryCreationFailed }
        let fileURL = folder.appending(path: context.fileName)
        
        do {
            let data = try processData(context: context)
            let result = try fileService.writeSync(data: data, to: .local(path: fileURL.path))
            return try await result.fileURL()
        } catch {
            throw ExportError.exportFailed
        }
    }
    
    // Получение папок для текущей операции
    private func getExportFolder() async throws -> URL {
        let mainFolder = appPaths.userOperationLocation(for: currentOperation)
        let url = try await mainFolder.fileURL()
        return url
    }
    
    // MARK: - Главный метод обработки данных
    private func processData(context: DataProcessingContext) throws -> Data {
        
        guard !context.items.isEmpty else {
            throw ExportError.invalidData
        }
        return try fileHandler.creator.createData(context: context)

    }
    
    // Остальные вспомогательные методы остаются теми же...
//    private func createDirectoriesIfNeeded(main: URL, backup: URL) -> Bool {
//        do {
//            if !fileManager.fileExists(atPath: main.path) {
//                try fileManager.createDirectory(at: main, withIntermediateDirectories: true)
//            }
//            if !fileManager.fileExists(atPath: backup.path) {
//                try fileManager.createDirectory(at: backup, withIntermediateDirectories: true)
//            }
//            return true
//        } catch {
//            print("❌ Ошибка создания папки: \(error)")
//            return false
//        }
//    }
    
}
