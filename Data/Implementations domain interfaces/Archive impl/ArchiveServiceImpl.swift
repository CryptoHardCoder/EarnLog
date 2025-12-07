//
//  ArchiveServiceImpl.swift
//  EarnLog
//
//  Created by M3 pro on 01/10/2025.
//

import Foundation

final class ArchiveServiceImpl: ArchiveServiceRepository {
    private let fileHandler: FileHandler
    private let metadataService: ArchiveMetadataServiceRepository
    private let appPaths: AppPathsBuilderRepository
    private let fileStorageService: FileStorageService
    private let backupFolder: StorageLocation
    private let userVisibleFolder: StorageLocation
    
    init(fileHandler: FileHandler, metadataService: ArchiveMetadataServiceRepository,
         appPaths: AppPathsBuilderRepository, fileStorageService: FileStorageService) {
        self.fileHandler = fileHandler
        self.metadataService = metadataService
        self.appPaths = appPaths
        self.fileStorageService = fileStorageService
        self.backupFolder = appPaths.backupLocation(for: .archive)
        self.userVisibleFolder = appPaths.userOperationLocation(for: .archive)
    }
    
    /// Создает архив данных за указанный период
    func createArchive(items: [IncomeEntry], format: FileFormat, config: FileConfiguration? = nil) async throws -> StorageLocation{
        let config = config ?? FileConfiguration.defaultArchive
        let context = DataProcessingContext(
            items: items, 
            configuration: config, 
        )
        
        do {
            let data = try fileHandler.creator.createData(context: context)
            let archiveLocation = try await fileStorageService.writeAsync(data, to: backupFolder)
            try await fileStorageService.copy(from: archiveLocation, to: userVisibleFolder)
            let metadata = try await metadataService.createArchiveMetadata(
                from: items, 
                fileName: context.fileName,
                format: format,
                fileURL: archiveLocation.fileURL().path
            )
            try await metadataService.saveArchiveMetadata(metadata)
            return archiveLocation
        } catch {
            throw ArchiveServiceError.archiveCreationFailed
        }
    }
    
    func loadItemsFromArchive(metadata: ArchiveMetadata) async throws -> [IncomeEntry] {
        let archiveFileLocation = StorageLocation.from(string: metadata.fileURL)
        guard let archiveFileLocation = archiveFileLocation else { throw ArchiveServiceError.archiveStorageUnavailable }
        
        do {
            return try await fileHandler.loader.load(from: archiveFileLocation)
        } catch {
            throw ArchiveServiceError.extractionFailed
        }
    }
    
    // TODO: format:  Получать из настроек пользователя
    func autoArchivation(items: [IncomeEntry]) async throws {
        do {
            _ = try await self.createArchive(items: items, format: .pdf)
        } catch {
            throw ArchiveServiceError.autoArchivationFailed
        }
    }
}
    
//    func loadItemsFromArchive(metadata: ArchiveMetadata) -> Result<[IncomeEntry], ArchiveError> {
//        let fileURL = appPaths.userOperationFolder(for: .archive)
//            .appendingPathComponent(metadata.fileName)
//        
//        return fileHandler.loader.load(from: fileURL)
//    }
   
        
        
//        DispatchQueue.global(qos: .utility).async { [weak self] in
//            guard let self = self else { return }
//            
//            let result = self.createArchive(
//                items: items,
//                format: .csv, // TODO: Получать из настроек пользователя
//                period: .month
//            )
//            
//            switch result {
//            case .success(let url):
//                print("Archive created successfully: \(url.lastPathComponent)")
//            case .failure(let error):
//                print("Archive creation failed: \(error)")
//            }
//        }
    
    
    
//    /// Создает архив данных за указанный период
//    func createArchive(items: [IncomeEntry], format: FileFormat, period: TimeFilter) -> Result<String, ArchiveError> {
//        let config = FileProcessingConfiguration.defaultArchive
//        let context = DataProcessingContext(
//            items: items, 
//            configuration: config, 
//        )
//        
//        let mainFolder = appPaths.userOperationLocation(for: .archive)
//        let backupFolder = appPaths.backupLocation(for: .archive)
//        do {
//            let result = try fileHandler.creator.createData(context: context)
//            return fileStorageService.write(result, to: )
//        } catch {
//            
//        }
//        
//        
//        if case .success(let url) = result {
//            // Сохраняем метаданные только при успешном создании архива
//            let metadata = metadataService.createArchiveMetadata(
//                from: items, 
//                fileName: url,
//                format: format
//            )
//            metadataService.saveArchiveMetadata(metadata)
//        }
//        
//        return result
//    }
//    
//    func loadItemsFromArchive(metadata: ArchiveMetadata) -> Result<[IncomeEntry], ArchiveError> {
//        let fileURL = appPaths.userOperationFolder(for: .archive)
//            .appendingPathComponent(metadata.fileName)
//        
//        return fileHandler.loader.load(from: fileURL)
//    }
//    
//    func autoArchivation(items: [IncomeEntry], year: Int, month: Int) -> Result<String, ArchiveError> {
//        DispatchQueue.global(qos: .utility).async { [weak self] in
//            guard let self = self else { return }
//            
//            let result = self.createArchive(
//                items: items,
//                format: .csv, // TODO: Получать из настроек пользователя
//                period: .month
//            )
//            
//            switch result {
//            case .success(let url):
//                print("Archive created successfully: \(url.lastPathComponent)")
//            case .failure(let error):
//                print("Archive creation failed: \(error)")
//            }
//        }
//    }

