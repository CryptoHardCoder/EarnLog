//
//  GetActiveSideJobsUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 16/10/2025.
//

import Foundation

protocol GetActiveSideJobsUseCase {
    func execute() async throws -> [SideJob]
}

final class GetActiveSideJobsUseCaseImpl: GetActiveSideJobsUseCase {
    private let sideJobsManager: SideJobManagerRepository
    init(sideJobsManager: SideJobManagerRepository) {
        self.sideJobsManager = sideJobsManager
    }
    func execute() async throws -> [SideJob] {
        try await sideJobsManager.loadActiveJobs()
    }
    
    
}
