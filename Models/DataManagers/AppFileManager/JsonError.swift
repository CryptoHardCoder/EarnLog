//
//  JsonError.swift
//  EarnLog
//
//  Created by M3 pro on 21/09/2025.
//


enum JsonError: Error, LocalizedError {
    case encoding
    case decoding
    
    var errorDescription: String? {
        switch self {
        case .encoding:
            return "Failed to encode JSON data"
        case .decoding:
            return "Failed to decode JSON data"
        }
    }
}