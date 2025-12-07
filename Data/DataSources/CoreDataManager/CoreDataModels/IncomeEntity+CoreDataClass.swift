//
//  IncomeEntity+CoreDataClass.swift
//  EarnLog
//
//  Created by M3 pro on 09/10/2025.
//
//

import Foundation
import CoreData


public class IncomeEntity: NSManagedObject {
    
}

// MARK: - IncomeEntity Extension
extension IncomeEntity {
    
    func toIncomeEntry() -> IncomeEntry {
        let source: IncomeSource
        if let sideJobEntity = sideJob{
            source = .sideJob(sideJobEntity.toSideJob())
        } else {
            source = .mainJob
        }
        let date = Date(timeIntervalSince1970: date)
        return IncomeEntry(date: date, 
                           jobTitle: jobTitle,
                           jobDescription: jobDescription,
                           price:price, 
                           isPaid: isPaid,
                           source: source)
    }
    
    /// Связывает с SideJobEntity используя NSManagedObjectID (вариант 1)
    func linkToSideJob(objectID: NSManagedObjectID) {
        guard let context = managedObjectContext else { return }
        
        // Проверяем текущую связь
        if let existing = self.sideJob, existing.objectID == objectID {
            return // Уже связано
        }
        
        // Получаем объект в текущем контексте
        guard let sideJobEntity = try? context.existingObject(with: objectID) as? SideJobEntity else {
            print("⚠️ Warning: Cannot get SideJobEntity with objectID \(objectID) in context")
            self.sideJob = nil
            return
        }
        
        self.sideJob = sideJobEntity
    }
    
    /// Связывает с SideJobEntity используя UUID (вариант 2 - резервный)
//    /// Использует синхронный fetch в текущем контексте
//    func linkToSideJobById(_ sideJobId: UUID) {
//        guard let context = managedObjectContext else { return }
//        
//        // Проверяем текущую связь
//        if let existing = self.sideJob, existing.id == sideJobId {
//            return // Уже связано
//        }
//        
//        // Синхронный fetch в текущем контексте
//        let fetchRequest = NSFetchRequest<SideJobEntity>(entityName: "SideJobEntity")
//        fetchRequest.predicate = NSPredicate(format: "id == %@", sideJobId as CVarArg)
//        fetchRequest.fetchLimit = 1
//        
//        do {
//            if let existing = try context.fetch(fetchRequest).first {
//                self.sideJob = existing
//            } else {
//                print("⚠️ Warning: SideJobEntity with id \(sideJobId) not found")
//                self.sideJob = nil
//            }
//        } catch {
//            print("❌ Error fetching SideJobEntity: \(error)")
//            self.sideJob = nil
//        }
//    }
}



//extension IncomeEntity {
//    convenience init(from item: IncomeEntry, context: NSManagedObjectContext) {
//        self.init(context: context)
//        self.id = item.id
//        self.date = item.date.timeIntervalSince1970
//        self.isPaid = item.isPaid
//        self.jobTitle = item.jobTitle
//        self.jobDescription = item.jobDescription
//        self.price = item.price
//        self.sourceName = item.source.displayName
//
//        switch item.source {
//        case .mainJob:
//            self.sideJob = nil
//        case .sideJob(let sideJob):
//            self.sideJob = SideJobEntity(from: sideJob, context: context)
//        }
//    }
//}
