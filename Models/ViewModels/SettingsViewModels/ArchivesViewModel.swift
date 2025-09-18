import Foundation

final class ArchivesViewModel: MemoryTrackable {
    
    private let fileManager = AppCoreServices.shared.appFileManager
    private let archiveManager =  AppCoreServices.shared.archiveManager
    // Приватные свойства для контроля обновления данных
    private var _archivesMetadata: [ArchiveMetadata] = []
    private var _archiveFiles: [String] = []
    
    // Публичные свойства только для чтения
    var archivesMetadata: [ArchiveMetadata] {
        return _archivesMetadata
    }
    
    var archiveFiles: [String] {
        return _archiveFiles
    }
    
    init() {
        cleanupDataInconsistencies()
        refreshData()
        trackCreation()
    }
    

    func refreshData() {
        _archivesMetadata = archiveManager.loadArchiveMetadata()
        _archiveFiles = archiveManager.getExistingArchiveFiles()
    }
    

    func getDataForCell() -> [(fileName: String, metadata: ArchiveMetadata)] {
        refreshData() // Обновляем данные перед возвратом
        
        var result: [(fileName: String, metadata: ArchiveMetadata)] = []
        
        for fileName in _archiveFiles {
            if let metadata = _archivesMetadata.first(where: { $0.fileName == fileName }) {
                result.append((fileName: fileName, metadata: metadata))
            }
        }
        
        return result
    }
    
    func getMetadata(for fileName: String) -> ArchiveMetadata? {
        return _archivesMetadata.first { $0.fileName == fileName }
    }
    
    func validateDataIntegrity() -> Bool {
        let metadataFileNames = Set(_archivesMetadata.map { $0.fileName })
        let existingFiles = Set(_archiveFiles)
        
        // Проверяем, что все файлы из метаданных существуют
        return metadataFileNames.isSubset(of: existingFiles)
    }
    
    private func cleanupDataInconsistencies() {
        archiveManager.cleanupArchiveInconsistencies()
    }
    
    deinit {
        trackDeallocation() // для анализа на memory leaks
    }
}
