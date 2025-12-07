//
//  String + ext.swift
//  JobData
//
//  Created by M3 pro on 27/07/2025.
//
import UIKit

extension String {
    
    static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter
    }
    
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
    
    func toDouble() -> Double? {
        // Создаем formatter с текущей локалью пользователя
        let formatter = Self.formatter
        // Пробуем распарсить с текущей локалью
        if let number = formatter.number(from: self) {
            print("number: \(number.doubleValue)")
            return number.doubleValue
        }
        
        // Если не получилось, пробуем заменить запятую на точку и наоборот
        let alternativeString = self.replacingOccurrences(of: ",", with: ".")
        if let number = formatter.number(from: alternativeString) {
            print("alternativeString: \(number.doubleValue)")
            return number.doubleValue
        }
        
        // Последняя попытка - стандартный Double init
        return Double(self)
    }
}

