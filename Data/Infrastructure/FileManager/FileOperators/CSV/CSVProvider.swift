//
//  CSVProvider.swift
//  EarnLog
//
//  Created by M3 pro on 29/09/2025.
//

import Foundation 

final class CSVProvider: FileHandler {
    
    lazy var creator: FileDataCreator = CSVCreator()
    
    lazy var parser: FileParser = CSVParser()
    
    lazy var loader: FileLoader = CSVLoader(csvParser: parser)

}
