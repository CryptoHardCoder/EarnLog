//
//  FileParser.swift
//  EarnLog
//
//  Created by M3 pro on 01/10/2025.
//
import Foundation

protocol FileParser {
    func parse(content: String) throws -> [IncomeEntry]
}
