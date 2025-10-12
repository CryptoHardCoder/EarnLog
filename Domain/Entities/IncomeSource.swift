//
//  IncomesSources.swift
//  EarnLog
//
//  Created by M3 pro on 31/07/2025.
//

import Foundation

enum IncomeSource: Codable, Hashable {
    case mainJob
    case sideJob(SideJob)
    
    var displayName: String {
        switch self {
            case .mainJob:
                return "primary".localized
            case .sideJob(let job):
                return job.isActive ? job.name : "\(job.name) \("deleted".localized)"
        }
    }
    
}

extension IncomeSource {
    static func fromDisplayName(_ name: String) -> IncomeSource {
        // Проверяем основную работу
        if name == IncomeSource.mainJob.displayName {
            return .mainJob
        }
        
        // Убираем суффикс "(удалено)" из названия для поиска
        let cleanName = name.replacingOccurrences(of: "deleted".localized, with: "").trimmingCharacters(in: .whitespaces)
        
        // Ищем среди существующих SideJob по очищенному названию
        if let match = SideJobManagerImpl.shared.getAllJobs().first(where: { sideJob in  sideJob.name.trimmingCharacters(in: .whitespaces) == cleanName }) {
//            print("match found for: \(cleanName)")
            return .sideJob(match)
        }
        
        // Если не найден, создаем новый с очищенным названием
//        print("new custom for parsed: \(cleanName)")
        return .sideJob(SideJob(id: UUID(), name: cleanName, isCustom: true, isActive: true))
    }
}

