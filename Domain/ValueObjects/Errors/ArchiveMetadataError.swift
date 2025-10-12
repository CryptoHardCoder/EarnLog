//
//  ArchiveMetadataError.swift
//  EarnLog
//
//  Created by M3 pro on 01/10/2025.
//
import Foundation 

enum ArchiveMetadataError: Error {
    case fileNotFound
    case encodingFailed
    case decodingFailed
    case writeFailed
    case saveFailed
    case extractionFailed
    case unknownError
}
