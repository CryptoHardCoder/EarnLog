//
//  DateStore.swift
//  EarnLog
//
//  Created by M3 pro on 30/09/2025.
//
import Foundation

protocol DateStoreRepository {
    func loadLastKnownDate() async throws -> Date
    func saveLastKnownDate(_ date: Date) async throws
}
