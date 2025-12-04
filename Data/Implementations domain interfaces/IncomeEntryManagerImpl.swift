//
//  CoreDataIncomeManagerImpl.swift
//  EarnLog
//
//  Created by M3 pro on 19/07/2025.
//
import Foundation
import CoreData

// MARK: - IncomeEntryManagerImpl
final class IncomeEntryManagerImpl: IncomeManagerRepository {
    
    private let sideJobManager: SideJobManagerRepository
    private let dataManager: CoreDataManagerRepository
    
    init(sideJobManager: SideJobManagerRepository, dataManager: CoreDataManagerRepository) {
        self.sideJobManager = sideJobManager
        self.dataManager = dataManager
    }
    
    func getAllItems() async throws -> [IncomeEntry] {
        let entities = try await dataManager.fetch(IncomeEntity.self){ $0.toIncomeEntry()}
        return entities
    }
    
    func addNewItem(item: IncomeEntry) async throws {
        
        let sideJobObjectID = try await validateAndGetSideJobObjectID(from: item.source)
        
        _ = try await dataManager.create(IncomeEntity.self) { entity in
            entity.id = item.id
            entity.date = item.date.timeIntervalSince1970
            entity.isPaid = item.isPaid
            entity.jobTitle = item.jobTitle
            entity.jobDescription = item.jobDescription
            entity.price = item.price
            entity.sourceName = item.source.displayName
            
            // Связываем с SideJobEntity используя ObjectID
            if let sideJobObjectID {
                entity.linkToSideJob(objectID: sideJobObjectID)
            }
        }
    }
    
    func deleteItem(withId id: UUID) async throws {
        try await dataManager.delete(id: id, type: IncomeEntity.self)
    }
    
    func updateItem(
        id: UUID?,
        ids: [UUID]?,
        newTitle: String?,
        newDescription: String?,
        newPrice: Double?,
        newDate: Date?,
        newStatus: Bool?,
        newSource: IncomeSource?
    ) async throws {
        let targetIds: [UUID]
        if let singleId = id {
            targetIds = [singleId]
        } else if let multipleIds = ids {
            targetIds = multipleIds
        } else {
            return
        }
        
        // Валидируем и получаем ObjectID если меняется source
        let sideJobObjectID = try await validateAndGetSideJobObjectID(from: newSource)
        
        for targetId in targetIds {
            try await dataManager.update(id: targetId, type: IncomeEntity.self) { entity in
                if let newDate {
                    entity.date = newDate.timeIntervalSince1970
                }
                if let newStatus {
                    entity.isPaid = newStatus
                }
                if let newTitle {
                    entity.jobTitle = newTitle
                }
                if let newDescription {
                    entity.jobDescription = newDescription
                }
                if let newPrice {
                    entity.price = newPrice
                }
                if let newSource {
                    entity.sourceName = newSource.displayName
                    
                    if let sideJobObjectID {
                        entity.linkToSideJob(objectID: sideJobObjectID)
                    } else {
                        entity.sideJob = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    /// Валидирует SideJob и возвращает NSManagedObjectID, или nil для mainJob
    private func validateAndGetSideJobObjectID(from source: IncomeSource?) async throws -> NSManagedObjectID? {
        guard case .sideJob(let sideJob) = source else {
            return nil
        }
        
        // Проверяем что SideJob существует в домене
        guard try await sideJobManager.getJobById(sideJob.id) != nil else {
            throw SideJobError.notFound(sideJob.id)
        }
        
        // Получаем ObjectID через dataManager
        return try await dataManager.fetchByID(SideJobEntity.self, id: sideJob.id)?.objectID
    }
}
