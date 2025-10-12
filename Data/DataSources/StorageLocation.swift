//
//  StorageLocation.swift
//  EarnLog
//
//  Created by M3 pro on 02/10/2025.
//
import Foundation

enum StorageLocation {
    case local(path: String)
    case cloud(url: URL)
    case cloudKit(containerID: String, recordID: String)
    
    /// Возвращает URL для добавления компонента
    func toFileURL(appendingComponent component: String) -> URL? {
        switch self {
        case .local(let path):
            return URL(filePath: path).appendingPathComponent(component)
        case .cloud(let url):
            return url.appendingPathComponent(component)
        case .cloudKit:
            return nil // CloudKit использует другой подход
        }
    }
    /// Создает StorageLocation из строки, автоматически определяя тип
    static func from(string: String) -> StorageLocation? {
        // Проверяем, является ли это URL
        if string.hasPrefix("http://") || string.hasPrefix("https://") {
            guard let url = URL(string: string) else { return nil }
            return .cloud(url: url)
        }

        // Проверяем CloudKit формат (например: "cloudkit://containerID/recordID")
        if string.hasPrefix("cloudkit://") {
            let components =
                string
                .replacingOccurrences(of: "cloudkit://", with: "")
                .split(separator: "/")
            guard components.count >= 2 else { return nil }
            return .cloudKit(
                containerID: String(components[0]),
                recordID: String(components[1])
            )
        }

        // Иначе - локальный путь
        return .local(path: string)
    }
        
    /// Создает новый StorageLocation с добавленным именем файла
    func with(fileName: String) -> StorageLocation {
        switch self {
        case .local(let path):
            let url = URL(filePath: path).appendingPathComponent(fileName)
            return .local(path: url.path)
        case .cloud(let url):
            return .cloud(url: url.appendingPathComponent(fileName))
        case .cloudKit(let containerID, let recordID):
            return .cloudKit(containerID: containerID, recordID: "\(recordID)/\(fileName)")
        }
    }
    
    /// Универсальный способ получить URL
    func fileURL() async throws -> URL {
        switch self {
        case .local(let path):
            return URL(filePath: path)
            
        case .cloud:
            throw NSError(domain: "StorageLocation", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Cloud загрузка не реализована"
            ])
            
        case .cloudKit:
            throw NSError(domain: "StorageLocation", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "CloudKit загрузка не реализована"
            ])
        }
    }
}
