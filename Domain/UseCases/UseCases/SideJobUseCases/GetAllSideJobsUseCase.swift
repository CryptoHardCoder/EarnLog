//
//  GetAllSideJobsUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//

import Foundation

protocol GetAllSideJobsUseCase{
    func execute() async throws -> [SideJob]
}

class GetAllSideJobsUseCasesImpl: GetAllSideJobsUseCase{
    private let sideJobStoregerepository: SideJobManagerRepository 
    
    init(repository: SideJobManagerRepository) {
        self.sideJobStoregerepository = repository
    }
    
    func execute() async throws -> [SideJob]{
        try await sideJobStoregerepository.getAllJobs()
    }
}
