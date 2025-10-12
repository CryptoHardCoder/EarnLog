//
//  PDFProvider.swift
//  EarnLog
//
//  Created by M3 pro on 29/09/2025.
//
import Foundation 

final class PDFProvider: FileHandler {
    
    lazy var creator: FileDataCreator = PDFCreator()
    
    lazy var parser: FileParser = PDFParser()
    
    lazy var loader: FileLoader = PDFLoader(pdfParser: parser)

}
