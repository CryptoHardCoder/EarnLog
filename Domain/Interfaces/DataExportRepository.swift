//
//  DataExportRepository.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//
import Foundation

protocol DataExportRepository{

    func exportData(items: [IncomeEntry]) async throws -> URL

//    func processData(context: DataProcessingContext, to format: FileFormat) -> Result<URL, DocumentCreatorError>
}
