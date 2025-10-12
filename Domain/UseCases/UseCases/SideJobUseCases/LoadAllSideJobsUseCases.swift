//
//  LoadAllSideJobsUseCases.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//

import Foundation

protocol LoadAllSideJobsUseCases{
    func execute() async -> [SideJob]
}

class LoadAllSideJobsUseCasesImpl: LoadAllSideJobsUseCases{
    private let sideJobStoregerepository: SideJobManagerRepository 
    
    init(repository: SideJobManagerRepository) {
        self.sideJobStoregerepository = repository
    }
    
    func execute() async -> [SideJob]{
        do {
            return try await sideJobStoregerepository.getAllJobs()
        } catch {
            return []
        }
    }
}
