//
//  DateStoreImpl.swift
//  EarnLog
//
//  Created by M3 pro on 30/09/2025.
//

import Foundation

final class DateStoreImpl: DateStoreRepository {
    private let appPaths: AppPathsBuilderRepository
    private let fileService: FileStorageService
    private let serializator: JSONSerializer
    private lazy var lastKnownDateFileURL = appPaths.jsonFileLocation(
        fileName: "LastKnownDate.json"
    )

    init(
        appPaths: AppPathsBuilderRepository,
        fileService: FileStorageService,
        serializator: JSONSerializer
    ) {
        self.appPaths = appPaths
        self.fileService = fileService
        self.serializator = serializator
    }

    func saveLastKnownDate(_ date: Date) async throws {
        let data = try serializator.encode(date)
            //            let data = try JSONEncoder().encode(date)
        _ = try await fileService.writeAsync(data, to: lastKnownDateFileURL)
            //            try data.write(to: lastKnownDateFileURL)
    }

    // Тоже асинхронный, потому что использует await
    func loadLastKnownDate() async throws -> Date? {
        guard try await fileService.exists(at: lastKnownDateFileURL) else {
            throw StorageError.fileNotFound
            return nil
        }

        let url = try await lastKnownDateFileURL.fileURL()
        let data = try Data(contentsOf: url)
        return try serializator.decode(Date.self, from: data)

    }
}
