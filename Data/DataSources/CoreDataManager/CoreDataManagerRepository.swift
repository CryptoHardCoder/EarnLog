//
//  CoreDataManagerRepository.swift
//  EarnLog
//
//  Created by M3 pro on 11/10/2025.
//

import Foundation
import CoreData

protocol CoreDataManagerRepository {
    func fetch<T: NSManagedObject>(
        _ type: T.Type,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?,
        limit: Int?
    ) async throws -> [T]
    
    func fetchByID<T: NSManagedObject>(_ type: T.Type, id: UUID) async throws -> T?
    
    func create<T: NSManagedObject>(
        _ type: T.Type,
        configure: @escaping (T) -> Void
    ) async throws -> T 
    
    func update<T: NSManagedObject>(id: UUID, type: T.Type, changes: @escaping (T) -> Void ) async throws
    
    func update(objectID: NSManagedObjectID, changes: @escaping (NSManagedObject) -> Void) async throws
    
    func delete<T: NSManagedObject>(id: UUID, type: T.Type) async throws
    
    func delete(objectID: NSManagedObjectID) async throws 
    
    func saveViewContext() async throws
    
}

extension CoreDataManagerRepository {
    
    /// Fetch с дефолтными значениями
    func fetch<T: NSManagedObject>(
        _ type: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil
    ) async throws -> [T] {
        try await fetch(
            type,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit
        )
    }
}
