//
//  CoreDataIncomeManagerImpl.swift
//  EarnLog
//
//  Created by M3 pro on 19/07/2025.
//
import Foundation
import CoreData

// MARK: - Implementation
final class IncomeEntryManagerImpl: MemoryTrackable {
    
//    static let shared = CoreDataIncomeManagerImpl()
    private let sideJobManager: SideJobManagerRepository
    
    lazy var persistentContainer: NSPersistentContainer =  {
        let container = NSPersistentContainer(name: "EarnLog")
        container.loadPersistentStores { _, error in
            if let error{
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    init(sideJobManager: SideJobManagerRepository){
        self.sideJobManager = sideJobManager
    }
}

extension IncomeEntryManagerImpl: IncomeManagerProtocol {
    
    func getAllItems() async throws -> [IncomeEntry] {
        let items = try await persistentContainer.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let fetchResult = try context.fetch(fetchRequest)
            return fetchResult.map { $0.toIncomeEntry() }
        }
        return items
    }
    
    func addNewItem(item: IncomeEntry) async throws {
        try await persistentContainer.performBackgroundTask { context in
            _ = IncomeEntity(from: item, context: context)
            try context.save()
        }
    }
    
    func deleteItem(withId id: UUID) async throws {
        try await persistentContainer.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)
            let entity = try context.fetch(fetchRequest).first
            guard let entity = entity else { return }
            context.delete(entity)
            try context.save()
        }
    }
    
    func updateItem(id: UUID?, ids: [UUID]?, 
                    newTitle: String?, newDescription: String?,
                    newPrice: Double?, newDate: Date?, 
                    newStatus: Bool?, newSource: IncomeSource?) async throws {
        let targetIds: [UUID]
        
        if let singleId = id {
            targetIds = [singleId]
        } else if let multipleIds = ids {
            targetIds = multipleIds
        } else {
            return
        }
        
        try await persistentContainer.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id IN %@", targetIds)
            let entities = try context.fetch(fetchRequest)
            for entity in entities {
                if let newDate{
                    entity.date = newDate.timeIntervalSince1970
                }
                if let newStatus{
                    entity.isPaid = newStatus
                }
                if let newTitle{
                    entity.jobTitle = newTitle
                }
                if let newDescription{
                    entity.jobDescription = newDescription
                }
                if let newPrice{
                    entity.price = newPrice
                }
                if let newSource{
                    entity.sourceName = newSource.displayName
                }

                let sideJobEntity = entity.sideJob
                switch newSource{
                    case .mainJob: entity.sideJob = nil
                    case .sideJob(let sideJob):
                        let existing = try? await sideJobManager.getJobById(sideJob.id)
                        guard let sideJobEntity = existing else { return }
                        entity.sideJob = existing ?? SideJobEntity(from: sideJob, context: context)
                    case .none:
                        break
                }
            }
            try context.save()
        }
    }
//    
//    func saveItems() -> Result<Void, IncomeManagerError> {
//        <#code#>
//    }
    
    
}
//    // MARK: - Properties
//    private var saveWorkItem: DispatchWorkItem?
//    private let jsonFileName = "allItems.json"
//    private let fileManager = FileManager.default
//    private let appPaths: LocalStoragePathBuilderImpl
//    
//    // Fixed: закрытая скобка
//    private(set) var allItems: [IncomeEntry] = []
//    
//    // MARK: - Sources
//    private let defaultSources: [IncomeSource] = [.mainJob]
//    
//    var customSources: [SideJob] {
//        SideJobStorageImpl.shared.loadAllJobs()
//    }
//    
//    var sources: [IncomeSource] {
//        defaultSources + customSources.map { .sideJob($0) }
//    }
//    
//    // MARK: - File URLs
//    private lazy var jsonFileURL = appPaths.jsonFileURL(fileName: jsonFileName)
//    private lazy var hiddenFolder = appPaths.hiddenFolder
//    private lazy var userAccessibleFolder = appPaths.userAccessibleFolder
//    private lazy var myApplicationSupportFilesFolder = appPaths.myApplicationSupportFilesFolderURL
//    
//    // MARK: - Initialization
//    init(appPaths: LocalStoragePathBuilderImpl) {
//        self.appPaths = appPaths
//        trackCreation()
//        
//        switch ensureFoldersExist() {
//        case .success:
//            loadItemsFromJSONFile()
//            checkAllItems()
//        case .failure(let error):
//            print("Failed to ensure folders exist: \(error)")
//            checkAllItems()
//        }
//    }
//    
//    deinit {
//        saveWorkItem?.cancel()
//        trackDeallocation()
//    }
//    
//    // MARK: - Private Methods
//    private func checkAllItems() {
//        if allItems.isEmpty {
//            createSampleData()
//        }
//    }
//    
//    private func checkAndUpdateCustomSources() {
//        for i in 0..<allItems.count {
//            if case let .sideJob(job) = allItems[i].source,
//               let sideJob = customSources.first(where: { $0.id == job.id }),
//               job != sideJob {
//                allItems[i].source = .sideJob(sideJob)
//            }
//        }
//    }
//    
//    private func ensureFoldersExist() -> Result<Void, IncomeManagerError> {
//        let foldersToCreate = [hiddenFolder, userAccessibleFolder, myApplicationSupportFilesFolder]
//        
//        for folderName in foldersToCreate {
//            if !fileManager.fileExists(atPath: folderName.path) {
//                do {
//                    try fileManager.createDirectory(
//                        atPath: folderName.path,
//                        withIntermediateDirectories: true
//                    )
//                } catch {
//                    return .failure(.folderCreationFailed(path: folderName.path))
//                }
//            }
//        }
//        return .success(())
//    }
//    
//    private func updateItemAt(
//        index: Int,
//        newCar: String?,
//        newPrice: Double?,
//        newDate: Date?,
//        newStatus: Bool?,
//        newSource: IncomeSource?
//    ) {
//        let currentItem = allItems[index]
//        let updatedItem = IncomeEntry(
//            date: newDate ?? currentItem.date,
//            jobDescription: newCar ?? currentItem.jobDescription,
//            price: newPrice ?? currentItem.price,
//            isPaid: newStatus ?? currentItem.isPaid,
//            source: newSource ?? currentItem.source
//        )
//        allItems[index] = updatedItem
//    }
//    
//    private func performSave() -> Result<Void, IncomeManagerError> {
//        switch ensureFoldersExist() {
//        case .failure(let error):
//            return .failure(error)
//        case .success:
//            break
//        }
//        
//        do {
//            let data = try JSONEncoder().encode(allItems)
//            try data.write(to: jsonFileURL)
//            return .success(())
//        } catch is EncodingError {
//            return .failure(.jsonError(.encoding))
//        } catch {
//            return .failure(.saveError(underlying: error))
//        }
//    }
//
//    
//    private func loadItemsFromJSONFile() {
//        guard fileManager.fileExists(atPath: jsonFileURL.path) else {
//            return
//        }
//        
//        do {
//            let data = try Data(contentsOf: jsonFileURL)
//            let items = try JSONDecoder().decode([IncomeEntry].self, from: data)
//            allItems = items
//        } catch is DecodingError {
//            print("Failed to decode items from JSON")
//        } catch {
//            print("Failed to load items: \(error)")
//        }
//    }
//    
//    private func createSampleData() {
//        let calendar = Calendar.current
//        let nowDate = Date()
//        
//        // Создаем дефолтные sideJob если customSources пустой
//        if customSources.isEmpty {
//            SideJobStorageImpl.shared.createExampleJobsIfNeeded()
//        }
//        
//        let availableCustomSources = customSources
//        guard let sideJob1 = customSources.first else { return }
//        
//        let sideJob2 = availableCustomSources.count > 1 ? availableCustomSources[1] : sideJob1
//        let customJob = availableCustomSources.last ?? sideJob1
//        
//        allItems = [
//            IncomeEntry(date: nowDate, car: "Proba", price: 120, isPaid: true, source: .sideJob(sideJob1)),
//            IncomeEntry(date: calendar.date(byAdding: .hour, value: -1, to: nowDate)!, car: "Example", price: 200, isPaid: false, source: .mainJob),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -1, to: nowDate)!, car: "Example", price: 200, isPaid: false, source: .sideJob(sideJob1)),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -2, to: nowDate)!, car: "Example", price: 200, isPaid: false, source: .mainJob),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -5, to: nowDate)!, car: "Example", price: 500, isPaid: true, source: .sideJob(customJob)),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -10, to: nowDate)!, car: "Example", price: 300, isPaid: false, source: .sideJob(sideJob1)),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -7, to: nowDate)!, car: "Example", price: 450, isPaid: true, source: .mainJob),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -3, to: nowDate)!, car: "Example", price: 350, isPaid: false, source: .sideJob(sideJob2)),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -4, to: nowDate)!, car: "Example", price: 1000, isPaid: false, source: .sideJob(sideJob2)),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -6, to: nowDate)!, car: "Example", price: 900, isPaid: false, source: .sideJob(customJob))
//        ]
//        
//        _ = saveItems()
//    }
//    
//    // MARK: - Public Methods
//    func deletePreviousMonthItems() -> Bool {
//        let calendar = Calendar.current
//        let today = Date()
//        
//        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else {
//            return false
//        }
//        
//        allItems.removeAll { item in
//            return item.date < startOfMonth
//        }
//        
//        _ = saveItems()
//        return true
//    }
//    
//    func updateSideJobInfo(updatedJob: SideJob) {
//        for i in 0..<allItems.count {
//            if case let .sideJob(job) = allItems[i].source, job.id == updatedJob.id {
//                allItems[i].source = .sideJob(updatedJob)
//            }
//        }
//        _ = saveItems()
//    }
//    
//    func getLastMonthItems() -> [IncomeEntry] {
//        let calendar = Calendar.current
//        let lastMonth = calendar.dateComponents([.month, .year], from: .now)
//        
//        return allItems.filter { item in
//            let itemMonth = calendar.dateComponents([.month, .year], from: item.date)
//            return itemMonth == lastMonth
//        }
//    }
//}
//
//// MARK: - Protocol Conformance
//extension CoreDataIncomeManagerImpl: IncomeManagerProtocol {
//    
//    func getAllItems() -> [IncomeEntry] {
//        return allItems
//    }
//    
//    func addNewItem(item: IncomeEntry) {
//        allItems.append(item)
//        _ = saveItems()
//    }
//    
//    func deleteItem(withId id: UUID) {
//        guard let index = allItems.firstIndex(where: { $0.id == id }) else {
//            return
//        }
//        
//        allItems.remove(at: index)
//        _ = saveItems()
//    }
//    
//    func updateItem(
//        id: UUID? = nil,
//        ids: [UUID]? = nil,
//        newCar: String? = nil,
//        newPrice: Double? = nil,
//        newDate: Date? = nil,
//        newStatus: Bool? = nil,
//        newSource: IncomeSource? = nil
//    ) {
//        let targetIds: [UUID]
//        
//        if let singleId = id {
//            targetIds = [singleId]
//        } else if let multipleIds = ids {
//            targetIds = multipleIds
//        } else {
//            return
//        }
//        
//        var hasChanges = false
//        
//        for itemId in targetIds {
//            if let index = allItems.firstIndex(where: { $0.id == itemId }) {
//                updateItemAt(
//                    index: index,
//                    newCar: newCar,
//                    newPrice: newPrice,
//                    newDate: newDate,
//                    newStatus: newStatus,
//                    newSource: newSource
//                )
//                hasChanges = true
//            }
//        }
//        
//        if hasChanges {
//            _ = saveItems()
//        }
//    }
//    
//    func saveItems() -> Result<Void, Error> {
//        var result: Result<Void, IncomeManagerError> = .failure(.invalidData)
//
//        DispatchQueue.global(qos: .background).sync { [weak self] in
//            guard let self = self else {
//                result = .failure(.invalidData)
//                return
//            }
//            result = self.performSave()
//        }
//
//        // Result<Void, IncomeManagerImplError> автоматически приводится к Result<Void, Error>
//        return result.mapError { $0 }
//    }
//    
//   
//}
//
//
//// MARK: - Implementation
//final class CoreDataIncomeManagerImpl: MemoryTrackable {
//    
//    // MARK: - Properties
//    private var saveWorkItem: DispatchWorkItem?
//    private let jsonFileName = "allItems.json"
//    private let fileManager = FileManager.default
//    private let appPaths: LocalStoragePathBuilderImpl
//    
//    // Fixed: закрытая скобка
//    private(set) var allItems: [IncomeEntry] = []
//    
//    // MARK: - Sources
//    private let defaultSources: [IncomeSource] = [.mainJob]
//    
//    var customSources: [SideJob] {
//        SideJobStorageImpl.shared.loadAllJobs()
//    }
//    
//    var sources: [IncomeSource] {
//        defaultSources + customSources.map { .sideJob($0) }
//    }
//    
//    // MARK: - File URLs
//    private lazy var jsonFileURL = appPaths.jsonFileURL(fileName: jsonFileName)
//    private lazy var hiddenFolder = appPaths.hiddenFolder
//    private lazy var userAccessibleFolder = appPaths.userAccessibleFolder
//    private lazy var myApplicationSupportFilesFolder = appPaths.myApplicationSupportFilesFolderURL
//    
//    // MARK: - Initialization
//    init(appPaths: LocalStoragePathBuilderImpl) {
//        self.appPaths = appPaths
//        trackCreation()
//        
//        switch ensureFoldersExist() {
//        case .success:
//            loadItemsFromJSONFile()
//            checkAllItems()
//        case .failure(let error):
//            print("Failed to ensure folders exist: \(error)")
//            checkAllItems()
//        }
//    }
//    
//    deinit {
//        saveWorkItem?.cancel()
//        trackDeallocation()
//    }
//    
//    // MARK: - Private Methods
//    private func checkAllItems() {
//        if allItems.isEmpty {
//            createSampleData()
//        }
//    }
//    
//    private func checkAndUpdateCustomSources() {
//        for i in 0..<allItems.count {
//            if case let .sideJob(job) = allItems[i].source,
//               let sideJob = customSources.first(where: { $0.id == job.id }),
//               job != sideJob {
//                allItems[i].source = .sideJob(sideJob)
//            }
//        }
//    }
//    
//    private func ensureFoldersExist() -> Result<Void, IncomeManagerError> {
//        let foldersToCreate = [hiddenFolder, userAccessibleFolder, myApplicationSupportFilesFolder]
//        
//        for folderName in foldersToCreate {
//            if !fileManager.fileExists(atPath: folderName.path) {
//                do {
//                    try fileManager.createDirectory(
//                        atPath: folderName.path,
//                        withIntermediateDirectories: true
//                    )
//                } catch {
//                    return .failure(.folderCreationFailed(path: folderName.path))
//                }
//            }
//        }
//        return .success(())
//    }
//    
//    private func updateItemAt(
//        index: Int,
//        newCar: String?,
//        newPrice: Double?,
//        newDate: Date?,
//        newStatus: Bool?,
//        newSource: IncomeSource?
//    ) {
//        let currentItem = allItems[index]
//        let updatedItem = IncomeEntry(
//            date: newDate ?? currentItem.date,
//            jobDescription: newCar ?? currentItem.jobDescription,
//            price: newPrice ?? currentItem.price,
//            isPaid: newStatus ?? currentItem.isPaid,
//            source: newSource ?? currentItem.source
//        )
//        allItems[index] = updatedItem
//    }
//    
//    private func performSave() -> Result<Void, IncomeManagerError> {
//        switch ensureFoldersExist() {
//        case .failure(let error):
//            return .failure(error)
//        case .success:
//            break
//        }
//        
//        do {
//            let data = try JSONEncoder().encode(allItems)
//            try data.write(to: jsonFileURL)
//            return .success(())
//        } catch is EncodingError {
//            return .failure(.jsonError(.encoding))
//        } catch {
//            return .failure(.saveError(underlying: error))
//        }
//    }
//
//    
//    private func loadItemsFromJSONFile() {
//        guard fileManager.fileExists(atPath: jsonFileURL.path) else {
//            return
//        }
//        
//        do {
//            let data = try Data(contentsOf: jsonFileURL)
//            let items = try JSONDecoder().decode([IncomeEntry].self, from: data)
//            allItems = items
//        } catch is DecodingError {
//            print("Failed to decode items from JSON")
//        } catch {
//            print("Failed to load items: \(error)")
//        }
//    }
//    
//    private func createSampleData() {
//        let calendar = Calendar.current
//        let nowDate = Date()
//        
//        // Создаем дефолтные sideJob если customSources пустой
//        if customSources.isEmpty {
//            SideJobStorageImpl.shared.createExampleJobsIfNeeded()
//        }
//        
//        let availableCustomSources = customSources
//        guard let sideJob1 = customSources.first else { return }
//        
//        let sideJob2 = availableCustomSources.count > 1 ? availableCustomSources[1] : sideJob1
//        let customJob = availableCustomSources.last ?? sideJob1
//        
//        allItems = [
//            IncomeEntry(date: nowDate, car: "Proba", price: 120, isPaid: true, source: .sideJob(sideJob1)),
//            IncomeEntry(date: calendar.date(byAdding: .hour, value: -1, to: nowDate)!, car: "Example", price: 200, isPaid: false, source: .mainJob),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -1, to: nowDate)!, car: "Example", price: 200, isPaid: false, source: .sideJob(sideJob1)),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -2, to: nowDate)!, car: "Example", price: 200, isPaid: false, source: .mainJob),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -5, to: nowDate)!, car: "Example", price: 500, isPaid: true, source: .sideJob(customJob)),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -10, to: nowDate)!, car: "Example", price: 300, isPaid: false, source: .sideJob(sideJob1)),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -7, to: nowDate)!, car: "Example", price: 450, isPaid: true, source: .mainJob),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -3, to: nowDate)!, car: "Example", price: 350, isPaid: false, source: .sideJob(sideJob2)),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -4, to: nowDate)!, car: "Example", price: 1000, isPaid: false, source: .sideJob(sideJob2)),
//            IncomeEntry(date: calendar.date(byAdding: .day, value: -6, to: nowDate)!, car: "Example", price: 900, isPaid: false, source: .sideJob(customJob))
//        ]
//        
//        _ = saveItems()
//    }
//    
//    // MARK: - Public Methods
//    func deletePreviousMonthItems() -> Bool {
//        let calendar = Calendar.current
//        let today = Date()
//        
//        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else {
//            return false
//        }
//        
//        allItems.removeAll { item in
//            return item.date < startOfMonth
//        }
//        
//        _ = saveItems()
//        return true
//    }
//    
//    func updateSideJobInfo(updatedJob: SideJob) {
//        for i in 0..<allItems.count {
//            if case let .sideJob(job) = allItems[i].source, job.id == updatedJob.id {
//                allItems[i].source = .sideJob(updatedJob)
//            }
//        }
//        _ = saveItems()
//    }
//    
//    func getLastMonthItems() -> [IncomeEntry] {
//        let calendar = Calendar.current
//        let lastMonth = calendar.dateComponents([.month, .year], from: .now)
//        
//        return allItems.filter { item in
//            let itemMonth = calendar.dateComponents([.month, .year], from: item.date)
//            return itemMonth == lastMonth
//        }
//    }
//}
//
//// MARK: - Protocol Conformance
//extension CoreDataIncomeManagerImpl: IncomeManagerProtocol {
//    
//    func getAllItems() -> [IncomeEntry] {
//        return allItems
//    }
//    
//    func addNewItem(item: IncomeEntry) {
//        allItems.append(item)
//        _ = saveItems()
//    }
//    
//    func deleteItem(withId id: UUID) {
//        guard let index = allItems.firstIndex(where: { $0.id == id }) else {
//            return
//        }
//        
//        allItems.remove(at: index)
//        _ = saveItems()
//    }
//    
//    func updateItem(
//        id: UUID? = nil,
//        ids: [UUID]? = nil,
//        newCar: String? = nil,
//        newPrice: Double? = nil,
//        newDate: Date? = nil,
//        newStatus: Bool? = nil,
//        newSource: IncomeSource? = nil
//    ) {
//        let targetIds: [UUID]
//        
//        if let singleId = id {
//            targetIds = [singleId]
//        } else if let multipleIds = ids {
//            targetIds = multipleIds
//        } else {
//            return
//        }
//        
//        var hasChanges = false
//        
//        for itemId in targetIds {
//            if let index = allItems.firstIndex(where: { $0.id == itemId }) {
//                updateItemAt(
//                    index: index,
//                    newCar: newCar,
//                    newPrice: newPrice,
//                    newDate: newDate,
//                    newStatus: newStatus,
//                    newSource: newSource
//                )
//                hasChanges = true
//            }
//        }
//        
//        if hasChanges {
//            _ = saveItems()
//        }
//    }
//    
//    func saveItems() -> Result<Void, Error> {
//        var result: Result<Void, IncomeManagerError> = .failure(.invalidData)
//
//        DispatchQueue.global(qos: .background).sync { [weak self] in
//            guard let self = self else {
//                result = .failure(.invalidData)
//                return
//            }
//            result = self.performSave()
//        }
//
//        // Result<Void, IncomeManagerImplError> автоматически приводится к Result<Void, Error>
//        return result.mapError { $0 }
//    }
//    
//   
//}
