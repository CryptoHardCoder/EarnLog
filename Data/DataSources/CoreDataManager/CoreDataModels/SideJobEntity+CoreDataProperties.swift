//
//  SideJobEntity+CoreDataProperties.swift
//  EarnLog
//
//  Created by M3 pro on 08/10/2025.
//
//

import Foundation
import CoreData


extension SideJobEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SideJobEntity> {
        return NSFetchRequest<SideJobEntity>(entityName: "SideJobEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var isActive: Bool
    @NSManaged public var isCustom: Bool
    @NSManaged public var name: String
    @NSManaged public var incomeEntries: NSSet?

}

// MARK: Generated accessors for incomeEntries
extension SideJobEntity {

    @objc(addIncomeEntriesObject:)
    @NSManaged public func addToIncomeEntries(_ value: IncomeEntity)

    @objc(removeIncomeEntriesObject:)
    @NSManaged public func removeFromIncomeEntries(_ value: IncomeEntity)

    @objc(addIncomeEntries:)
    @NSManaged public func addToIncomeEntries(_ values: NSSet)

    @objc(removeIncomeEntries:)
    @NSManaged public func removeFromIncomeEntries(_ values: NSSet)

}

extension SideJobEntity : Identifiable {

}
