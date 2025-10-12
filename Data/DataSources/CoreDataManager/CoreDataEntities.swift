//
//  CoreDataEntities.swift
//  EarnLog
//
//  Created by M3 pro on 08/10/2025.
//

import Foundation

enum CoreDataEntities: String {
    case incomeEntity
    case sideJobEntity
    
    var name: String {
        rawValue.capitalized
    }
}
