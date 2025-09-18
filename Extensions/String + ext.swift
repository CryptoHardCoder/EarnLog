//
//  String + ext.swift
//  JobData
//
//  Created by M3 pro on 27/07/2025.
//
import UIKit

extension String {
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    // MARK: - Расширение String для регулярных выражений
    func ranges(of searchString: String, options: String.CompareOptions = []) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
              let range = self.range(of: searchString, options: options, range: searchStartIndex..<self.endIndex) {
            ranges.append(range)
            searchStartIndex = range.upperBound
        }
        
        return ranges
    }
    
    func matches(_ pattern: String) -> Bool {
        return self.range(of: pattern, options: .regularExpression) != nil
    }
}
