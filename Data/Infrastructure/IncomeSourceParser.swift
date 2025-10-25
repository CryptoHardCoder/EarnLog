//
//  IncomeSourceParser.swift
//  EarnLog
//
//  Created by M3 pro on 12/10/2025.
//
import Foundation

class IncomeSourceParser {
    static func fromDisplayName(_ name: String, allJobs: [SideJob]) -> IncomeSource {
        if name == IncomeSource.mainJob.displayName {
            return .mainJob
        }
        let cleanName = name.replacingOccurrences(of: "deleted".localized, with: "").trimmingCharacters(in: .whitespaces)
        if let match = allJobs.first(where: { $0.name.trimmingCharacters(in: .whitespaces) == cleanName }) {
            return .sideJob(match)
        }
        return .sideJob(SideJob(id: UUID(), name: cleanName, isCustom: true, isActive: true))
    }
}
