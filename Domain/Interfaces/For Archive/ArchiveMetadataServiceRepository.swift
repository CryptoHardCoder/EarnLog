//
//  ArchiveMetadataRepository.swift
//  EarnLog
//
//  Created by M3 pro on 30/09/2025.
//
import Foundation

protocol ArchiveMetadataServiceRepository {
    func loadArchiveMetadata() async throws -> [ArchiveMetadata]
    func saveArchiveMetadata(_ metadata: ArchiveMetadata) async throws
    func createArchiveMetadata(from items: [IncomeEntry], 
                               fileName: String, 
                               format: FileFormat,
                               fileURL: String) async throws -> ArchiveMetadata
}



//func loadArchiveMetadata() -> Result<[ArchiveMetadata], ArchiveMetadataError>
//func saveArchiveMetadata(_ metadata: ArchiveMetadata) -> Result<Void, ArchiveMetadataError>
//func createArchiveMetadata(from items: [IncomeEntry], 
//                           fileName: String, 
//                           format: FileFormat) -> ArchiveMetadata
