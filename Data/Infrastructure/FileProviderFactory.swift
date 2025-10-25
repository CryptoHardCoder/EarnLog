//
//  FileProviderFactory.swift
//  EarnLog
//
//  Created by M3 pro on 29/09/2025.
//

import Foundation

final class FileProviderFactory {
    static func makeProvider(for format: FileFormat, sideJobManager: SideJobManagerRepository) -> FileHandler{
        switch format {
            case .csv: return CSVProvider(sideJobManager: sideJobManager)
            case .pdf: return PDFProvider(sideJobManager: sideJobManager)
        }
    }
}
