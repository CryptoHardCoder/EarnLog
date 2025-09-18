//
//  ExportConfiguration.swift
//  EarnLog
//
//  Created by M3 pro on 28/08/2025.
//
import Foundation
import UIKit


// MARK: - Конфигурация обработки файлов
struct FileProcessingConfiguration {
    // Основные настройки
    let title: String                 
    let dateFormat: String           
    let includeTotal: Bool           
    let operation: DataOperation      // Новое поле для типа операции
    
    // PDF настройки
    let maxRowsPerPage: Int          
    let pageSize: CGSize             
    
    // Брендинг для PDF
    let appName: String              
    let appLogo: UIImage?            
    let primaryColor: UIColor        
    let secondaryColor: UIColor      
    
    // Стандартная конфигурация для экспорта
    static let defaultExport = FileProcessingConfiguration(
        title: "Exported Data",
        dateFormat: "dd.MM.yyyy",
        includeTotal: true,
        operation: .export,
        maxRowsPerPage: 35,
        pageSize: CGSize(width: 595, height: 842),
        appName: "iTracker",
        appLogo: UIImage(named: "icon"),
        primaryColor: UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),
        secondaryColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    )
    
    // Стандартная конфигурация для архивации
    static let defaultArchive = FileProcessingConfiguration(
        title: "Archived Data",
        dateFormat: "dd.MM.yyyy",
        includeTotal: true,
        operation: .archive,
        maxRowsPerPage: 35,
        pageSize: CGSize(width: 595, height: 842),
        appName: "iTracker",
        appLogo: UIImage(named: "icon"),
        primaryColor: UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0), // Другой цвет для архива
        secondaryColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    )
}
