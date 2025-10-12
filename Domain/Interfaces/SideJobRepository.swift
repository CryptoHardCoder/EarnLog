//
//  SideJobRepository.swift
//  EarnLog
//
//  Created by M3 pro on 26/09/2025.
//
import Foundation

protocol SideJobManagerRepository {
    func loadActiveJobs() async throws -> [SideJob]
    func getAllJobs() async throws -> [SideJob]
    func saveNewJob(job: SideJob) async throws
    func updateJob(id: UUID, newName: String) async throws
    func deleteJob(id: UUID) async throws
    func getJobById(_ id: UUID) async throws -> SideJob?
}
