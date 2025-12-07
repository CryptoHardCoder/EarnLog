//
//  ArchiveManagerImpl.swift
//  EarnLog
//
//  Created by M3 pro on 28/09/2025.
//
import Foundation

// MARK: - Archive Manager
final class ArchiveManagerImpl: ArchiveManagerRepository, MemoryTrackable {
    // MARK: - Dependencies
    private let incomeManager: IncomeManagerProtocol
    private let fileProvider: DocumentProvider
    private let dateStore: DateStoreRepository
    private let metadataService: ArchiveMetadataServiceRepository
    private let appPaths: AppPaths = AppPaths()
    private let fileManager = FileManager.default
    
    
    // MARK: - File URLs
    private lazy var userVisibleFolder = appPaths.userOperationFolder(for: .archive)
    
    private lazy var backupFolder = appPaths.backupFolder(for: .archive)
    
    
    // MARK: - Initialization
    init(incomeManager: IncomeManagerProtocol, fileProvider: DocumentProvider) {
        self.incomeManager = incomeManager
        self.fileProvider = fileProvider
        trackCreation()
        ensureRequiredFoldersExist()
    }
    
    deinit {
        trackDeallocation()
    }
    
    // MARK: - Public Interface
    
    /// Проверяет необходимость архивации при запуске приложения
    func checkArchiveOnAppStart() {
        let today = Date()
        let calendar = Calendar.current
        
        guard let lastKnownDate = dateStore.loadLastKnownDate() else {
            dateStore.saveLastKnownDate(today)
            return
        }
        
        let todayComponents = calendar.dateComponents([.year, .month], from: today)
        let lastComponents = calendar.dateComponents([.year, .month], from: lastKnownDate)
        
        let isNewMonth = todayComponents.year != lastComponents.year || 
                        todayComponents.month != lastComponents.month
        
        if isNewMonth {
            let itemsToArchive = getItemsForPeriod(
                year: lastComponents.year ?? 0, 
                month: lastComponents.month ?? 0
            )
            
            if !itemsToArchive.isEmpty {
                autoArchivation(
                    items: itemsToArchive,
                    year: lastComponents.year ?? 0,
                    month: lastComponents.month ?? 0
                )
            }
        }
        
        dateStore.saveLastKnownDate(today)
    }
    
    /// Создает архив данных за указанный период
    func createArchive(items: [IncomeEntry], format: FileFormat, period: TimeFilter) -> Result<URL, DocumentProviderError> {
        let config = FileProcessingConfiguration.defaultArchive
        let context = DataProcessingContext(
            items: items, 
            configuration: config, 
        )
        
        let result = fileProvider.creator.create(context: context, 
                                                 folders: (main: userVisibleFolder, backup: backupFolder))
        
        if case .success(let url) = result {
            // Сохраняем метаданные только при успешном создании архива
            let metadata = metadataService.createArchiveMetadata(
                from: items, 
                fileName: url.lastPathComponent,
                format: format
            )
            metadataService.saveArchiveMetadata(metadata)
        }
        
        return result
    }
    
    func loadItemsFromArchive(metadata: ArchiveMetadata) -> Result<[IncomeEntry], DocumentProviderError> {
        let fileURL = appPaths.userOperationFolder(for: .archive)
            .appendingPathComponent(metadata.fileName)
        
        return fileProvider.loader.load(from: fileURL)
    }
    
    /// Получает список доступных периодов (текущий + архивные)
    func getAvailablePeriods() -> [ArchivePeriod] {
        var periods: [ArchivePeriod] = []
        
        // Добавляем текущий период если есть данные
        let currentItems = incomeManager.getAllItems()
        if !currentItems.isEmpty {
            let calendar = Calendar.current
            let now = Date()
            let currentPeriod = ArchivePeriod(
                year: calendar.component(.year, from: now),
                month: calendar.component(.month, from: now),
                itemsCount: currentItems.count,
            )
            periods.append(currentPeriod)
        }
        
        // Добавляем архивные периоды
        let archivedPeriods = metadataService.loadArchiveMetadata().map { metadata in
            ArchivePeriod(
                year: metadata.year,
                month: metadata.month, 
                itemsCount: metadata.itemsCount,
                fileName: metadata.fileName,
                format: metadata.fileFormat
            )
        }
        
        periods.append(contentsOf: archivedPeriods)
        
        // Сортируем по убыванию даты
        return periods.sorted { first, second in
            if first.year != second.year {
                return first.year > second.year
            }
            return first.month > second.month
        }
    }
    
    /// Загружает элементы за указанный период
    func loadItemsForPeriod(year: Int, month: Int) -> Result<[IncomeEntry], DocumentProviderError> {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        
        // Если запрашиваем текущий период - берем из памяти
        if year == currentYear && month == currentMonth {
            return .success(getItemsForPeriod(year: year, month: month))
        }
        
        // Иначе ищем в архивах
        guard let metadata = metadataService.loadArchiveMetadata().first(where: { 
            $0.year == year && $0.month == month 
        }) else {
            return .failure(.noData)
        }
        
        return loadItemsFromArchive(metadata: metadata)
    }
    
    
    
    // MARK: - Private Methods
    
    private func ensureRequiredFoldersExist() {
        let foldersToCreate = [
            appPaths.userOperationFolder(for: .archive),
            appPaths.backupFolder(for: .archive),
            appPaths.myApplicationSupportFilesFolderURL
        ]
        
        for folder in foldersToCreate {
            if !fileManager.fileExists(atPath: folder.path) {
                try? fileManager.createDirectory(
                    at: folder, 
                    withIntermediateDirectories: true
                )
            }
        }
    }
    
    private func autoArchivation(items: [IncomeEntry], year: Int, month: Int) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            
            let result = self.createArchive(
                items: items,
                format: .csv, // TODO: Получать из настроек пользователя
                period: .month
            )
            
            switch result {
            case .success(let url):
                print("Archive created successfully: \(url.lastPathComponent)")
            case .failure(let error):
                print("Archive creation failed: \(error)")
            }
        }
    }
    
    private func getItemsForPeriod(year: Int, month: Int) -> [IncomeEntry] {
        let calendar = Calendar.current
        
        return incomeManager.getAllItems().filter { item in
            let itemYear = calendar.component(.year, from: item.date)
            let itemMonth = calendar.component(.month, from: item.date)
            return itemYear == year && itemMonth == month
        }
    }

}

