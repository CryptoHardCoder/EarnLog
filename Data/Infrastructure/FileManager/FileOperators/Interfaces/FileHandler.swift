//
//  FileProvider.swift
//  EarnLog
//
//  Created by M3 pro on 29/09/2025.
//
import Foundation

protocol FileHandler {
    var creator: any FileDataCreator { get }
    var loader: FileLoader { get }
    var parser: FileParser { get }
}
