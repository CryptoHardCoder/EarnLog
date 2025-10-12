//
//  JSONSerializatorStore.swift
//  EarnLog
//
//  Created by M3 pro on 01/10/2025.
//
import Foundation

final class JSONSerializatorStore: JSONSerializer {
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func encode<T>(_ value: T) throws -> Data where T : Encodable {
        do {
            return try encoder.encode(value)
        } catch {
            throw SerializationError.encodingFailed
        }
    }
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw SerializationError.decodingFailed
        }
    }
    
    
}
