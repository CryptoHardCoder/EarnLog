//
//  FileStorage.swift
//  EarnLog
//
//  Created by M3 pro on 01/10/2025.
//
import Foundation

protocol FileStorageService {
    func read(from url: URL) -> Result<Data, StorageError>
    func write(_ data: Data, to url: URL) -> Result<Void, StorageError>
    func fileExists(at url: URL) -> Bool
}
