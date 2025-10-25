//
//  PDFLoader.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//

import Foundation
import PDFKit

final class PDFLoader: FileLoader {

    private let pdfParser: FileParser
    
    init(pdfParser: FileParser) {
        self.pdfParser = pdfParser
    }
    
    func load(from path: StorageLocation) async throws -> [IncomeEntry] {
        let urlPdf = try await path.fileURL()
        
        guard let pdfDocument = PDFDocument(url: urlPdf) else {
            throw FileHandlerError.invalidPath
        }
        var items: [IncomeEntry] = []
        
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex),
                  let pageText = page.string else { continue }
            
            let pageItems = try pdfParser.parse(content: pageText)
            items.append(contentsOf: pageItems)
        }
    
        return items.sorted { $0.date > $1.date }
    }
    
}
