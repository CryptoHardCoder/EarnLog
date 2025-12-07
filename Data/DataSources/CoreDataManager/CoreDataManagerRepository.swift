//
//  CoreDataManagerRepository.swift
//  EarnLog
//
//  Created by M3 pro on 11/10/2025.
//

import Foundation
import CoreData

protocol CoreDataManagerRepository {
    // Версия с transform - для domain моделей
    func fetch<T: NSManagedObject, R>(
        _ type: T.Type,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?,
        limit: Int?,
        transform: @escaping (T) -> R
    ) async throws -> [R]
    
    // Версия без transform - для entities
    func fetch<T: NSManagedObject>(
        _ type: T.Type,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?,
        limit: Int?
    ) async throws -> [T]
    
    // fetchByID с transform - для domain модели
    func fetchByID<T: NSManagedObject, R>(
        _ type: T.Type, 
        id: UUID,
        transform: @escaping (T) -> R
    ) async throws -> R?
    
    // fetchByID без transform - для entity
    func fetchByID<T: NSManagedObject>(
        _ type: T.Type, 
        id: UUID
    ) async throws -> T?
    
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
    func fetch<T: NSManagedObject, R>(
        _ type: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil,
        transform:  @escaping (T) -> R
    ) async throws -> [R] {
        try await fetch(
            type,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit, 
            transform:  transform
        )
    }
}
