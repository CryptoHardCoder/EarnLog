//
//  ExportConfiguration.swift
//  EarnLog
//
//  Created by M3 pro on 28/08/2025.
//
import Foundation
import UIKit

// MARK: - Конфигурация экспорта
struct FileProcessingConfiguration {
    // Основные настройки
    let title: String                 // Заголовок документа
    let dateFormat: String           // Формат даты (например "dd.MM.yyyy")
    let includeTotal: Bool           // Включать ли итоговую строку
    
    // PDF настройки
    let maxRowsPerPage: Int          // Максимум строк на странице PDF
    let pageSize: CGSize             // Размер страницы (A4 = 595x842)
    
    // Брендинг для PDF
    let appName: String              // Название приложения
    let appLogo: UIImage?            // Логотип приложения (может быть nil)
    let primaryColor: UIColor        // Основной цвет (для заголовков)
    let secondaryColor: UIColor      // Вторичный цвет (для подписей)
    
    // Стандартная конфигурация по умолчанию
    static let `default` = FileProcessingConfiguration(
        title: "Exported Data",
        dateFormat: "dd.MM.yyyy",
        includeTotal: true,
        maxRowsPerPage: 35,
        pageSize: CGSize(width: 595, height: 842), // A4
        appName: "Your App Name",
        appLogo: UIImage(named: "icon"),
        primaryColor: UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),
        secondaryColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    )
}


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
        appName: "Your App Name",
        appLogo: UIImage(named: "app_logo"),
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
        appName: "Your App Name",
        appLogo: UIImage(named: "app_logo"),
        primaryColor: UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0), // Другой цвет для архива
        secondaryColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    )
}
