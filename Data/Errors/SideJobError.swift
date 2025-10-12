//
//  SideJobError.swift
//  EarnLog
//
//  Created by M3 pro on 11/10/2025.
//
import Foundation

enum SideJobError: LocalizedError {
    case duplicateName(String)
    case notFound(UUID)
    
    var errorDescription: String? {
        switch self {
        case .duplicateName(let name):
            return "Подработка с именем '\(name)' уже существует"
        case .notFound(let id):
            return "Подработка с ID \(id) не найдена"
        }
    }
}
