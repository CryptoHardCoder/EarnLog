//
//  JSONSerializer.swift
//  EarnLog
//
//  Created by M3 pro on 01/10/2025.
//
import Foundation

protocol JSONSerializer {
    func encode<T: Encodable>(_ value: T) throws -> Data
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

//
//protocol JSONSerializer {
//    func encode<T: Encodable>(_ value: T) -> Result<Data, SerializationError>
//    func decode<T: Decodable>(_ type: T.Type, from data: Data) -> Result<T, SerializationError>
//}
