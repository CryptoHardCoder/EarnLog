//
//  ArchiveMetadataImpl.swift
//  EarnLog
//
//  Created by M3 pro on 30/09/2025.
//
import Foundation

final class ArchiveMetadataImpl: ArchiveMetadataServiceRepository{
    private let storage: FileStorageService
    private let serializer: JSONSerializer
    private let metadataLocation: StorageLocation
    
    init(
        storage: FileStorageService,
        serializer: JSONSerializer,
        appPaths: AppPathsBuilderRepository
    ) {
        self.storage = storage
        self.serializer = serializer
        self.metadataLocation = appPaths.jsonFileLocation(fileName: "ArchiveMetadata.json")
    }
    
    // MARK: - Metadata Management
    func loadArchiveMetadata() async throws -> [ArchiveMetadata] {
        let exists = try await storage.exists(at: metadataLocation)
        guard exists else { throw ArchiveMetadataError.fileNotFound }
        do {
            let data = try await storage.read(from: metadataLocation)
            return try serializer.decode([ArchiveMetadata].self, from: data)
        } catch is StorageError {
            throw ArchiveMetadataError.extractionFailed
        } catch is SerializationError {
            throw ArchiveMetadataError.decodingFailed
        } catch {
            throw ArchiveMetadataError.unknownError}
    }
    
    func saveArchiveMetadata(_ metadata: ArchiveMetadata) async throws {
        var allMetadata: [ArchiveMetadata]
        
        do {
            allMetadata = try await loadArchiveMetadata()
        } catch ArchiveMetadataError.fileNotFound {
            allMetadata = []
        } catch {
            throw error
        }
        
        allMetadata.removeAll { $0.year == metadata.year && $0.month == metadata.month }
        allMetadata.append(metadata)
        try await saveAllMetadata(allMetadata)
    }

    func createArchiveMetadata(
        from items: [IncomeEntry], 
        fileName: String,
        format: FileFormat,
        fileURL: String
    ) -> ArchiveMetadata {
        let calendar = Calendar.current
        let firstDate = items.first?.date ?? Date()
        
        return ArchiveMetadata(
            year: calendar.component(.year, from: firstDate),
            month: calendar.component(.month, from: firstDate),
            itemsCount: items.count,
            fileName: fileName,
            createdAt: Date(), 
            fileFormat: format,
            fileURL: fileURL
        )
    }
    
    private func saveAllMetadata(_ allMetadata: [ArchiveMetadata]) async throws{
        let sortedMetadata = allMetadata.sorted { first, second in
            if first.year != second.year {
                return first.year > second.year
            }
            return first.month > second.month
        }
        do {
            let encoded = try serializer.encode(sortedMetadata)
            _ = try await storage.writeAsync(encoded, to: metadataLocation)
        } catch is SerializationError {
            throw ArchiveMetadataError.encodingFailed
        } catch is StorageError{
            throw ArchiveMetadataError.writeFailed
        } catch {
            throw ArchiveMetadataError.unknownError
        } 
    }
    
//    private func saveAllMetadata(_ allMetadata: [ArchiveMetadata]) -> Result<Void, ArchiveMetadataError> {
//        let sortedMetadata = allMetadata.sorted { first, second in
//            if first.year != second.year {
//                return first.year > second.year
//            }
//            return first.month > second.month
//        }
//        
//        return serializer.encode(sortedMetadata)
//            .mapError { _ in .encodingFailed }
//            .flatMap { data in
//                storage.write(data, to: metadataFileURL.path)
//                    .mapError { _ in .writeFailed }
//            }
//    }
    
//    /// Очищает несогласованности в архивах
//    private func cleanupArchiveInconsistencies() {
//        let metadata = loadArchiveMetadata()
//        let validMetadata = metadata.filter { meta in
//            let fileURL = appPaths.userOperationFolder(for: .archive)
//                .appendingPathComponent(meta.fileName)
//            return fileManager.fileExists(atPath: fileURL.path)
//        }
//        
//        if validMetadata.count != metadata.count {
//            replaceArchiveMetadata(validMetadata)
//        }
//    }
}
