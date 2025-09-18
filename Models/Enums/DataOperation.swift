//
//  DataOperation.swift
//  EarnLog
//
//  Created by M3 pro on 28/08/2025.
//


import Foundation
import UIKit
import PDFKit


// MARK: - Enum для типа операции
enum DataOperation {
    case export    // Экспорт данных
    case archive   // Архивация данных
    
    var folderName: String {
        switch self {
        case .export: return "Exports"
        case .archive: return "Archives" 
        }
    }
    
    var backupFolderName: String {
        switch self {
        case .export: return "ExportsBackup"
        case .archive: return "ArchivesBackup"
        }
    }
}