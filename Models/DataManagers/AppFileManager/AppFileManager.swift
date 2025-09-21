//
//  AppFileManager.swift
//  JobData
//
//  Created by M3 pro on 19/07/2025.
//
import Foundation
import UIKit

class AppFileManager: MemoryTrackable {
    
    private var saveWorkItem: DispatchWorkItem?
    
    private let jsonFileName = "allItems.json"
    
//    private let myApplicationSupportFilesFolder = "My Application Support Files"

    private let fileManager = FileManager.default
    
    private(set) var allItems: [IncomeEntry] = []
    
    let defaultSources: [IncomeSource] = [.mainJob]
    
    var customSources: [IncomeSource.SideJob] {
        SideJobStorage.shared.loadAllCustomJobs()
    }

    var sources: [IncomeSource] {
        defaultSources + customSources.map { .sideJob($0) }
    }
    
    private lazy var jsonFileURL = appPaths.jsonFileURL(fileName: jsonFileName)
    private lazy var hiddenFolder = appPaths.hiddenFolder
    private lazy var userAccessibleFolder = appPaths.userAccessibleFolder
    private lazy var myApplicationSupportFilesFolder = appPaths.myApplicationSupportFilesFolderURL
    
    private let appPaths: AppPaths
    
    init(appPaths: AppPaths) {
        self.appPaths = appPaths
        trackCreation()
        let _ = ensureFoldersExist()
        checkAllItems()
    }
    
    private func checkAllItems(){
        if allItems.isEmpty {
            createSampleData()
//            print("checkAllItems: \(allItems)")
        } 
    }
    

    // MARK: - Обновление allItems на соответствие sideJob значений
    private func checkAndUpdateCustomSources(){
        
        for i in 0..<allItems.count {
            if case let .sideJob(job) = allItems[i].source, 
                let sideJob = customSources.first(where: { $0.id == job.id }),
                job != sideJob  {
                allItems[i].source = .sideJob(sideJob)
            }
        }
    }

    func ensureFoldersExist() -> AppFileManagerResult<Void> {
        let foldersToCreate = [hiddenFolder, userAccessibleFolder, myApplicationSupportFilesFolder]
        
        for folderName in foldersToCreate {
            if !fileManager.fileExists(atPath: folderName.path) {
                do{
                    try fileManager.createDirectory(atPath: folderName.path, 
                                                    withIntermediateDirectories: true)
                } catch {
                    return .failure(.folderCreationFailed(path: folderName.path))
                }
            }
        }
        return .success(())
    }
    
    func deletePreviousMonthItems() -> Bool {
        let calendar = Calendar.current
        let today = Date()
        
        // Берём первый день текущего месяца
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else { return false}
        // Удаляем все даты, которые меньше начала этого месяца
        allItems.removeAll { item in
            return item.date < startOfMonth
        }
        let _ = saveItems()
        return true
        
    }

    // Вспомогательный метод для избежания дублирования кода
    private func updateItemAt(index: Int, newCar: String?, newPrice: Double?, newDate: Date?, newStatus: Bool?, newSource: IncomeSource?) {
        let currentItem = allItems[index]
        let updatedItem = IncomeEntry(
            date: newDate ?? currentItem.date,
            car: newCar ?? currentItem.car,
            price: newPrice ?? currentItem.price,
            isPaid: newStatus ?? currentItem.isPaid,
            source: newSource ?? currentItem.source
        )
        allItems[index] = updatedItem
    }
    
    
    func updateSideJobInfo(updatedJob: IncomeSource.SideJob) {
        for i in 0..<allItems.count {
            if case let .sideJob(job) = allItems[i].source, job.id == updatedJob.id {
                allItems[i].source = .sideJob(updatedJob)
            }
        }
        let _ = saveItems()
        
    }
    

    
    private func performSave() -> AppFileManagerResult<Void> {
        
        switch ensureFoldersExist(){
            case .failure(let error): 
                return .failure(error)
            case .success(()):
                break
        }
        
        do {
            let data = try JSONEncoder().encode(allItems)
            try data.write(to: jsonFileURL)
            return .success(())
        } catch let encodingError as EncodingError{
            return .failure(.jsonError(.encoding))
        } catch {
            return .failure(.jsonError(.decoding))
        }
        
    }
    
    func loadItemsFromJSONFile() -> AppFileManagerResult<[IncomeEntry]> {
        guard fileManager.fileExists(atPath: jsonFileURL.path) else {
            return .failure(.fileNotFound(name: jsonFileName))
        }
        
        do {
            let data = try Data(contentsOf: jsonFileURL)
            let items = try JSONDecoder().decode([IncomeEntry].self, from: data)
            allItems = items
            return .success(items)
        } catch let decodingError as DecodingError {
            return .failure(.jsonError(.decoding))
        } catch {
            return .failure(.loadError(underlying: error))
        }
//        print("📂 jsonFileURL:", jsonFileURL.path)
    }
        
    func createSampleData() {
        let calendar = Calendar.current
        let nowDate = Date()
        
        // Создаем дефолтные sideJob если customSources пустой
        if customSources.isEmpty {
            SideJobStorage.shared.createExampleJobsIfNeeded()
        }
        let availableCustomSources = customSources
        
        guard let sideJob1 = customSources.first else { return }
        let sideJob2 = availableCustomSources.count > 1 ? availableCustomSources[1] : sideJob1
        let customJob = availableCustomSources.last ?? sideJob1
        
        allItems = [
            IncomeEntry(date: nowDate, car: "Proba", price: 120, isPaid: true, source: .sideJob(sideJob1)),
            IncomeEntry(date: calendar.date(byAdding: .hour, value: -1, to: nowDate)!, car: "Excample", price: 200, isPaid: false, source: .mainJob),
            IncomeEntry(date: calendar.date(byAdding: .day, value: -1, to: nowDate)!, car: "Excample", price: 200, isPaid: false, source: .sideJob(sideJob1)),
            IncomeEntry(date: calendar.date(byAdding: .day, value: -2, to: nowDate)!, car: "Excample", price: 200, isPaid: false, source: .mainJob),
            IncomeEntry(date: calendar.date(byAdding: .day, value: -5, to: nowDate)!, car: "Excample", price: 500, isPaid: true, source: .sideJob(customJob)),
            IncomeEntry(date: calendar.date(byAdding: .day, value: -10, to: nowDate)!, car: "Excample", price: 300, isPaid: false, source: .sideJob(sideJob1)),
            IncomeEntry(date: calendar.date(byAdding: .day, value: -7, to: nowDate)!, car: "Excample", price: 450, isPaid: true, source: .mainJob),
            IncomeEntry(date: calendar.date(byAdding: .day, value: -3, to: nowDate)!, car: "Excample", price: 350, isPaid: false, source: .sideJob(sideJob2)),
            IncomeEntry(date: calendar.date(byAdding: .day, value: -4, to: nowDate)!, car: "Excample", price: 1000, isPaid: false, source: .sideJob(sideJob2)),
            IncomeEntry(date: calendar.date(byAdding: .day, value: -6, to: nowDate)!, car: "Excample", price: 900, isPaid: false, source: .sideJob(customJob))
        ]
        
        let _ = saveItems()
    }
    
   
    
    /// Загружает данные или создаёт тестовые, если файл пустой/не существует.
    /// Выполняется в фоне, а по завершении вызывает completion на главном потоке.
    func loadOrCreateInBackground(completion: @escaping (AppFileManagerResult<[IncomeEntry]>) -> Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let loadResult = self.loadItemsFromJSONFile()
            
            let finalResult: AppFileManagerResult<[IncomeEntry]>
            
            switch loadResult {
                case .success(let items):
                    if items.isEmpty {
                        self.createSampleData()
                        finalResult = .success(self.allItems)
                    } else {
                        finalResult = .success(items)
                    }
                    
                case .failure(.fileNotFound):
                    self.createSampleData()
                    finalResult = .success(self.allItems)
                case .failure(let error): 
                    finalResult = .failure(error)
            }
            
            // Сообщим UI, что данные обновились
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
                completion(finalResult)
            }
        }
    }
    
    
    deinit {
        trackDeallocation() // для анализа на memory leaks
    }
    
}

//MARK: Confirm protocol DataProvider
extension AppFileManager: DataProvider{

    func getAllItems() -> AppFileManagerResult<[IncomeEntry]> {
        return .success(allItems)
    }
    
    func addNewItem(_ item: IncomeEntry) -> AppFileManagerResult<Void> {
        allItems.append(item)
        let saveResult = saveItems()
        return saveResult
    }
    
    func deleteItem (withId id: UUID) -> AppFileManagerResult<Void> {
        guard let index = allItems.firstIndex(where: { $0.id == id }) else {
            return .failure(.itemNotFound(id: id))
        }
        
        allItems.remove(at: index)
        let saveResult = saveItems()
        return saveResult
    }
    
    func updateItem(
        for id: UUID? = nil,
        for ids: [UUID]? = nil,
        newCar: String? = nil,
        newPrice: Double? = nil,
        newDate: Date? = nil,
        newStatus: Bool? = nil,
        newSource: IncomeSource? = nil
    ) -> AppFileManagerResult<Void> {
        // Собираем список ID для обновления
        let targetIds: [UUID]
        
        if let singleId = id {
            targetIds = [singleId]
        } else if let multipleIds = ids {
            targetIds = multipleIds
        } else {
            return .failure(.invalidData)
        }
        
        for itemId in targetIds {
            if let index = allItems.firstIndex(where: { $0.id == itemId }) {
                updateItemAt(
                    index: index,
                    newCar: newCar,
                    newPrice: newPrice,
                    newDate: newDate,
                    newStatus: newStatus,
                    newSource: newSource
                )
            } else {
                return .failure(.itemNotFound(id: itemId))
            }
        }
        // Сохраняем и уведомляем один раз в конце
        let saveResult = saveItems()
        return saveResult
    }
    
    
    func saveItems() -> AppFileManagerResult<Void> {
        // Отменяем предыдущее отложенное сохранение
        saveWorkItem?.cancel()
        
        // Создаем новую задачу с weak self для избежания retain cycle
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let _ = self.performSave()
            
            // Уведомляем UI об изменениях после сохранения
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
            }
        }
        
        saveWorkItem = workItem
        
        // Запускаем отложенное сохранение
        DispatchQueue.global(qos: .background).async(execute: workItem)
        
        // Возвращаем успех, так как сохранение запланировано
        return .success(())
    }

}
