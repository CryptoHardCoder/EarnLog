//
//  FileCreator.swift
//  EarnLog
//
//  Created by M3 pro on 29/09/2025.
//
import Foundation

protocol FileDataCreator {
    func createData(context: DataProcessingContext) throws -> Data
}

//
//protocol FileCreator {
//    func create(context: DataProcessingContext, 
//                folders: (mainLocation: StorageLocation, 
//                          backupLocation: StorageLocation)) -> Result<StorageLocation, FileHandlerError>
//}
