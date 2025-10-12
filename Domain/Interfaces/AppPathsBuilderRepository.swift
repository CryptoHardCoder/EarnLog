//
//  AppPathsProvider.swift
//  EarnLog
//
//  Created by M3 pro on 02/10/2025.
//
import Foundation

protocol AppPathsBuilderRepository {
    func jsonFileLocation(fileName: String) -> StorageLocation
    func userOperationLocation(for operation: DataOperation) -> StorageLocation
    func backupLocation(for operation: DataOperation) -> StorageLocation
}
