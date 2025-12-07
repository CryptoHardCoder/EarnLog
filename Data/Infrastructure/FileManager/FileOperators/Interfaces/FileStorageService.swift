//
//  FileStorage.swift
//  EarnLog
//
//  Created by M3 pro on 01/10/2025.
//
import Foundation

//protocol FileStorageService {
//    func read(from path: String) -> Result<Data, StorageError>
//    func write(_ data: Data, to path: String) -> Result<Void, StorageError>
//    func fileExists(at path: String) -> Bool
//}
protocol FileStorageService {
    func read(from location: StorageLocation) async throws -> Data
    func writeAsync(_ data: Data, to location: StorageLocation) async throws -> StorageLocation
    func delete(at location: StorageLocation) async throws
    func exists(at location: StorageLocation) async throws -> Bool
    func copy(from location: StorageLocation, to destination: StorageLocation) async throws
    func readSync(from location: StorageLocation) throws -> Data
    func writeSync(data: Data, to location: StorageLocation) throws -> StorageLocation
}
