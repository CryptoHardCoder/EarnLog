//
//  ArchiveService.swift
//  EarnLog
//
//  Created by M3 pro on 01/10/2025.
//

import Foundation

protocol ArchiveServiceRepository {
    
    func createArchive(items: [IncomeEntry],
                       format: FileFormat, 
                       config: FileConfiguration?) async throws -> StorageLocation
    
    func loadItemsFromArchive(metadata: ArchiveMetadata) async throws -> [IncomeEntry]
    
    func autoArchivation(items: [IncomeEntry]) async throws
}

//protocol ArchiveServiceRepository {
//    
//    func createArchive(items: [IncomeEntry],
//                       format: FileFormat, 
//                       storage: StorageLocation) -> Result<String, ArchiveError>
//    
//    func loadItemsFromArchive(metadata: ArchiveMetadata) -> Result<[IncomeEntry], ArchiveError>
//    
//    func autoArchivation(items: [IncomeEntry], year: Int, month: Int) -> Result<String, ArchiveError>
//}


//protocol ArchiveServiceRepository {
//    func createArchive(items: [IncomeEntry], format: FileFormat, period: TimeFilter) -> Result<String, ArchiveError>
//    func loadItemsFromArchive(metadata: ArchiveMetadata) -> Result<[IncomeEntry], ArchiveError>
//    func autoArchivation(items: [IncomeEntry], year: Int, month: Int) -> Result<String, ArchiveError>
//}
