//
//  FileLoader.swift
//  EarnLog
//
//  Created by M3 pro on 01/10/2025.
//
import Foundation

protocol FileLoader {
    func load(from path: StorageLocation) async throws -> [IncomeEntry] 
}
