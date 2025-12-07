//
//  SideJob.swift
//  EarnLog
//
//  Created by M3 pro on 26/09/2025.
//
import Foundation

struct SideJob: Codable, Hashable, Equatable {
    let id: UUID
    var name: String
    let isCustom: Bool
    var isActive: Bool
}
