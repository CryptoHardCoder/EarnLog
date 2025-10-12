//
//  StorageError.swift
//  EarnLog
//
//  Created by M3 pro on 01/10/2025.
//
import Foundation

enum StorageError: Error {
    case fileNotFound
    case readFailed
    case writeFailed
    case incompatibleStorageType
    case networkError
    case uploadFailed
    case deletionFailed
    case permissionDenied
}
