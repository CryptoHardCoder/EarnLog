//
//  SideJobEntity+CoreDataClass.swift
//  EarnLog
//
//  Created by M3 pro on 08/10/2025.
//
//

import Foundation
import CoreData


public class SideJobEntity: NSManagedObject {
    
    func toSideJob() -> SideJob {
        return SideJob(id: self.id,
                       name: self.name, 
                       isCustom: self.isCustom,
                       isActive: self.isActive)
    }

}


extension SideJobEntity {
    convenience init(from type: SideJob, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = type.id
        self.name = type.name
        self.isActive = type.isActive
        self.isCustom = type.isCustom
    }
}
