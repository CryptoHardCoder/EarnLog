//
//  ExportError.swift
//  EarnLog
//
//  Created by M3 pro on 01/10/2025.
//
import Foundation

enum ExportError: Error {
    case exportFailed
    case dataProcessingFailed
    case storageUnavailable
    case invalidData
}
