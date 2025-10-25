//
//  CoreDataManager.swift
//  EarnLog
//
//  Created by M3 pro on 11/10/2025.
//

import Foundation
import CoreData

final class CoreDataManager: CoreDataManagerRepository {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EarnLog")
        container.loadPersistentStores { desc, error in
            if let error {
                fatalError("Failed to load persistent store: \(error)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // Версия с transform
    func fetch<T: NSManagedObject, R>(
        _ type: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil,
        transform: @escaping (T) -> R
    ) async throws -> [R] {
        let fetchRequest = NSFetchRequest<T>(
            entityName: String(describing: T.self)
        )
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.relationshipKeyPathsForPrefetching = ["sideJob"]
        if let limit {
            fetchRequest.fetchLimit = limit
        }
        
        return try await persistentContainer.performBackgroundTask{ context in
            let results = try context.fetch(fetchRequest)
            return results.map(transform)
        }
    }

    // Версия без transform
    func fetch<T: NSManagedObject>(
        _ type: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil
    ) async throws -> [T] {
        let fetchRequest = NSFetchRequest<T>(
            entityName: String(describing: T.self)
        )
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.relationshipKeyPathsForPrefetching = ["sideJob"]
        if let limit {
            fetchRequest.fetchLimit = limit
        }
        
        return try await persistentContainer.performBackgroundTask{ context in
            try context.fetch(fetchRequest)
        }
    }
    
    
    // fetchByID с transform
    func fetchByID<T: NSManagedObject, R>(
        _ type: T.Type, 
        id: UUID,
        transform: @escaping (T) -> R
    ) async throws -> R? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try await fetch(type, predicate: predicate, limit: 1, transform: transform).first
    }

    // fetchByID без transform
    func fetchByID<T: NSManagedObject>(
        _ type: T.Type, 
        id: UUID
    ) async throws -> T? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try await fetch(type, predicate: predicate, limit: 1).first
    }
    
    func create<T: NSManagedObject>(
        _ type: T.Type,
        configure: @escaping (T) -> Void
    ) async throws -> T {
        return try await persistentContainer.performBackgroundTask { context in
            let entity = T(context: context)
            configure(entity)
            try context.save()
            return entity
        }
    }
    
    func update<T: NSManagedObject>(id: UUID, type: T.Type, changes: @escaping (T) -> Void ) async throws {
        try await persistentContainer.performBackgroundTask { context in
            let request = NSFetchRequest<T>(
                entityName: String(describing: T.self)
            )
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
                
            guard let entity = try context.fetch(request).first else {
                throw CoreDataError.entityNotFound
            }
            changes(entity)
            try context.save()
        }
    }
    
    func update(objectID: NSManagedObjectID, changes: @escaping (NSManagedObject) -> Void) async throws {
        try await persistentContainer.performBackgroundTask { context in
            let object = try context.existingObject(with: objectID)
            changes(object)
            try context.save()
        }
    }
    
    func delete<T: NSManagedObject>(id: UUID, type: T.Type) async throws {
        try await persistentContainer.performBackgroundTask { context in
            let request = NSFetchRequest<T>(
                entityName: String(describing: T.self)
            )
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
                
            guard let entity = try context.fetch(request).first else {
                throw CoreDataError.entityNotFound
            }
            context.delete(entity)
            try context.save()
        }
    }
    
    func delete(objectID: NSManagedObjectID) async throws {
        try await persistentContainer.performBackgroundTask { context in
            let object = try context.existingObject(with: objectID)
            context.delete(object)
            try context.save()
        }
    }
    
    func saveViewContext() async throws {
        let context = viewContext
        guard context.hasChanges else { return }
        try await context.perform {
            try context.save()
        }
    }
}
