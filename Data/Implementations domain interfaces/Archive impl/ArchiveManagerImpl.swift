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
    private let dateStore: DateStoreRepository
    private let metadataService: ArchiveMetadataServiceRepository

    private let archiveService: ArchiveServiceRepository
    
    // MARK: - Initialization
    init(incomeManager: IncomeManagerProtocol, dateStore: DateStoreRepository, metadataService: ArchiveMetadataServiceRepository, appPaths: AppPathsBuilderRepository, fileStorageService: FileStorageService, archiveService: ArchiveServiceRepository) {
        self.incomeManager = incomeManager
        self.dateStore = dateStore
        self.metadataService = metadataService
        self.archiveService = archiveService
    }
    
    deinit {
        trackDeallocation()
    }
    
    // MARK: - Public Interface
    /// Проверяет необходимость архивации при запуске приложения
    func checkArchiveOnAppStart() async throws {
        let today = Date()
        let calendar = Calendar.current
        
        guard let lastKnownDate = try? await dateStore.loadLastKnownDate() else {
            try? await dateStore.saveLastKnownDate(today)
            return
        }
        
        let todayComponents = calendar.dateComponents([.year, .month], from: today)
        let lastComponents = calendar.dateComponents([.year, .month], from: lastKnownDate)
        
        let isNewMonth = todayComponents.year != lastComponents.year || 
                        todayComponents.month != lastComponents.month
        
        if isNewMonth {
            let items = try await incomeManager.getAllItems()
            let itemsToArchive = DataFilter.getItemsForPeriod(
                items: items, 
                year: lastComponents.year ?? 0, 
                month: lastComponents.month ?? 0
            )
            
            if !itemsToArchive.isEmpty {
               try? await archiveService.autoArchivation(items: itemsToArchive)
            }
        }
        
//        dateStore.saveLastKnownDate(today)
    }

    /// Получает список доступных периодов
    func getAvailablePeriods() async -> [ArchivePeriod] {
        var periods: [ArchivePeriod] = []
        let archivesInMetadata = try? await metadataService.loadArchiveMetadata()
        guard let archivesInMetadata = archivesInMetadata else { return [] }
        archivesInMetadata.forEach { metadata in
            let period = ArchivePeriod(year: metadata.year,
                                       month: metadata.month,
                                       itemsCount: metadata.itemsCount,
                                       fileName: metadata.fileName,
                                       format: metadata.fileFormat,
                                       fileURL: metadata.fileURL)
            periods.append(period)
        }
        // Сортируем по убыванию даты
        return periods.sorted { first, second in
            if first.year != second.year {
                return first.year > second.year
            }
            return first.month < second.month
        }
    }
    
    /// Загружает элементы за указанный период
    func loadItemsForPeriod(year: Int, month: Int) async -> Result<[IncomeEntry], ArchiveServiceError> {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        
        // Если запрашиваем текущий период - берем из памяти
        if year == currentYear && month == currentMonth {
            let items = try? await incomeManager.getAllItems()
            guard let items = items else { return .failure(.archiveNotFound) }
            return .success(DataFilter.getItemsForPeriod(items: items, year: year, month: month))
        }
        
        // Иначе ищем в архивах
        guard let metadata = try? await metadataService.loadArchiveMetadata().first(where: { 
            $0.year == year && $0.month == month 
        }) else {
            return .failure(.archiveStorageUnavailable)
        }
        
        do {
             let items = try await archiveService.loadItemsFromArchive(metadata: metadata)
             return .success(items)
        } catch {
            return .failure(.extractionFailed)
        }
        
    }

}

