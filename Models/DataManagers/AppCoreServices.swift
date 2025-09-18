//
//  AppCoreServices.swift
//  EarnLog
//
//  Created by M3 pro on 18/09/2025.
//

import Foundation

class AppCoreServices {
    static let shared = AppCoreServices()
    
    // Создаются ЗДЕСЬ в правильном порядке
    lazy var appPaths = AppPaths()
    
    lazy var appFileManager = AppFileManager(appPaths: appPaths)
    
    lazy var dataFilter = DataFilter(dataProvider: appFileManager)
    
    lazy var dataService = UniversalDataService(appFileManager: appFileManager, appPaths: appPaths)
    
    lazy var archiveManager = ArchiveManager(fileManager: appFileManager, 
                                             appPaths: appPaths, 
                                             dataService: dataService)
    
    lazy var statisticsCalculator = StatisticsCalculator(dataProvider: appFileManager)
    
    private init() {}
}
