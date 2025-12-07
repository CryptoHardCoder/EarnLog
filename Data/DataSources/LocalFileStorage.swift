//
//  LocalStorage.swift
//  EarnLog
//
//  Created by M3 pro on 30/09/2025.
//

import Foundation

// MARK: - Локальное хранилище
class LocalFileStorage: FileStorageService {
    
    private let fileManager = FileManager.default
    
    func read(from location: StorageLocation) async throws -> Data {
        // Явно выполняем в фоновом потоке
        return try await Task.detached(priority: .userInitiated) {
            try self.readSync(from: location)
        }.value
    }
    
    func readSync(from location: StorageLocation) throws -> Data {
        guard case .local(let path) = location else {
            throw StorageError.incompatibleStorageType
        }
        return try Data(contentsOf: URL(filePath: path))
    }
    
    func writeAsync(_ data: Data, to location: StorageLocation) async throws -> StorageLocation {
        return try await Task.detached(priority: .userInitiated) {
            try self.performWrite(data: data, to: location)
        }.value
    }
    
    func writeSync(data: Data, to location: StorageLocation) throws -> StorageLocation {
        return try performWrite(data: data, to: location)
    }
    
    // Общая синхронная логика
    private func performWrite(data: Data, to location: StorageLocation) throws -> StorageLocation {
        guard case .local(let path) = location else {
            throw StorageError.incompatibleStorageType
        }
        
        let url = URL(filePath: path)
        let directory = url.deletingLastPathComponent()
        
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        
        try data.write(to: url)
        return location
    }
    
    func delete(at location: StorageLocation) async throws {
        try await Task.detached(priority: .userInitiated) {
            guard case .local(let path) = location else {
                throw StorageError.incompatibleStorageType
            }
            
            let url = URL(filePath: path)
            if self.fileManager.fileExists(atPath: url.path) {
                try self.fileManager.removeItem(at: url)
            }
        }.value
    }
    
    func exists(at location: StorageLocation) async throws -> Bool {
        return try await Task.detached(priority: .userInitiated) {
            guard case .local(let path) = location else {
                throw StorageError.incompatibleStorageType
            }
            return self.fileManager.fileExists(atPath: path)
        }.value
    }
    
    func copy(from source: StorageLocation, to destination: StorageLocation) async throws {
        try await Task.detached(priority: .userInitiated) {
            guard case .local(let sourcePath) = source,
                  case .local(let destPath) = destination else {
                throw StorageError.incompatibleStorageType
            }
            
            let sourceURL = URL(filePath: sourcePath)
            let destURL = URL(filePath: destPath)
            
            guard self.fileManager.fileExists(atPath: sourcePath) else {
                throw FileHandlerError.invalidPath
            }
            
            try self.fileManager.copyItem(at: sourceURL, to: destURL)
        }.value
    }
    
}

//final class LocalStorage: FileStorageService {
//    
//    private let fileManager: FileManager
//    
//    init(fileManager: FileManager = .default) {
//        self.fileManager = fileManager
//    }
//    
//    func read(from path: String) -> Result<Data, StorageError> {
//        guard fileManager.fileExists(atPath: path) else { return .failure(.fileNotFound)}
//        
//        do {
//            let url = URL(filePath: path)
//            let data = try Data(contentsOf: url)
//            return .success(data)
//        } catch {
//            return .failure(.readFailed)
//        }
//    }
//    
//    func write(_ data: Data, to path: String) -> Result<Void, StorageError> {
//        do {
//            let url = URL(filePath: path)
//            try data.write(to: url)
//            return .success(())
//        } catch {
//            return .failure(.writeFailed)
//        }
//    }
//    
//    func fileExists(at path: String) -> Bool {
//        fileManager.fileExists(atPath: path) 
//    }
//    
//    
//}
