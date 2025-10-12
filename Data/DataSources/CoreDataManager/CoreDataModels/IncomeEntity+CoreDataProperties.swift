//
//  IncomeEntity+CoreDataProperties.swift
//  EarnLog
//
//  Created by M3 pro on 09/10/2025.
//
//

import Foundation
import CoreData


extension IncomeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IncomeEntity> {
        return NSFetchRequest<IncomeEntity>(entityName: "IncomeEntity")
    }

    @NSManaged public var date: TimeInterval
    @NSManaged public var id: UUID
    @NSManaged public var isPaid: Bool
    @NSManaged public var jobTitle: String
    @NSManaged public var price: Double
    @NSManaged public var sourceName: String
    @NSManaged public var jobDescription: String?
    @NSManaged public var sideJob: SideJobEntity?

}
