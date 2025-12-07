//
//  CSVProvider.swift
//  EarnLog
//
//  Created by M3 pro on 29/09/2025.
//

import Foundation 

final class CSVProvider: FileHandler {
    
    private let sideJobManager: SideJobManagerRepository
    
    lazy var creator: FileDataCreator = CSVCreator()
    
    lazy var parser: FileParser = CSVParser(sideJobManager: sideJobManager)
    
    lazy var loader: FileLoader = CSVLoader(csvParser: parser)
    
    init(sideJobManager: SideJobManagerRepository) {
        self.sideJobManager = sideJobManager
    }

}
