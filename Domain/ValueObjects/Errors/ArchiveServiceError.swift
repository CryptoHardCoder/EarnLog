//
//  ArchiveError.swift
//  EarnLog
//
//  Created by M3 pro on 01/10/2025.
//
import Foundation

enum ArchiveServiceError: Error {
    case archiveCreationFailed
    case archiveNotFound
    case corruptedArchive
    case extractionFailed
    case archiveStorageUnavailable
    case autoArchivationFailed
}
