//
//  AppFileManager.swift
//  JobData
//
//  Created by M3 pro on 19/07/2025.
//
import Foundation
import UIKit

class AppFileManager: MemoryTrackable {
    
    static let shared = AppFileManager()
    
    private lazy var dataService = UniversalDataService()
    
    private let appPaths = AppPaths.shared 
    
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
    private lazy var myApplicationSupportFilesFolderURL = appPaths.myApplicationSupportFilesFolderURL
//    private var jsonFileURL: URL {
//        myApplicationSupportFilesFolderURL.appending(path: jsonFileName)
//    }
//    var hiddenFolder: URL {
//        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
//    }
//    
//    var userAccessibleFolder: URL {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    }
//    
//    var myApplicationSupportFilesFolderURL: URL {
//        hiddenFolder.appending(path: myApplicationSupportFilesFolder)
//    }
       
    
    private init() {
        trackCreation()
        ensureFoldersExist()
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
    
    func ensureFoldersExist() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: hiddenFolder.path) {
            try? fileManager.createDirectory(at: hiddenFolder, withIntermediateDirectories: true)
        }
        if !fileManager.fileExists(atPath: userAccessibleFolder.path) {
            try? fileManager.createDirectory(at: userAccessibleFolder, withIntermediateDirectories: true)
        }
        if !fileManager.fileExists(atPath: myApplicationSupportFilesFolderURL.path) {
            try? fileManager.createDirectory(at: myApplicationSupportFilesFolderURL, withIntermediateDirectories: true)
        }
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
        saveItems()
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
        saveItems()
        
    }
    

    
    private func performSave() {
        do {
            try fileManager.createDirectory(at: myApplicationSupportFilesFolderURL,
                                           withIntermediateDirectories: true, 
                                            attributes: nil)
            let data = try JSONEncoder().encode(allItems)
            try data.write(to: jsonFileURL)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
            }
        } catch {
            //TODO: создать енум для таких серьезных ошибок
            // Логирование ошибки
            print("Save error: \(error)")
        }
    }
    
    func loadItemsFromJSONFile() {
        guard fileManager.fileExists(atPath: jsonFileURL.path) else {
            print("Файл не найден, создаём sampleData")
            createSampleData()
            return
        }
        do {
            let data = try Data(contentsOf: jsonFileURL)
            allItems = try JSONDecoder().decode([IncomeEntry].self, from: data)
        } catch {
            print("Ошибка при загрузке JSON: \(error)")
            createSampleData()
        }
        print("📂 jsonFileURL:", jsonFileURL.path)
    }
    

    // Экспорт данных
    func exportData<T: Exportable>(_ items: [T], format: FileFormat, period: TimeFilter) -> URL? {
        let config = FileProcessingConfiguration.defaultExport
        let context = DataProcessingContext(items: items, configuration: config, period: period)
        
        let result = dataService.processData(context: context, to: format)
        
        switch result {
        case .success(let url):
            print("✅ Экспорт успешен: \(url)")
            return url
        case .failure(let error):
            print("❌ Ошибка экспорта: \(error.localizedDescription)")
            return nil
        }
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
        
        saveItems()
    }
    
   
    
    /// Загружает данные или создаёт тестовые, если файл пустой/не существует.
    /// Выполняется в фоне, а по завершении вызывает completion на главном потоке.
    func loadOrCreateInBackground(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.loadItemsFromJSONFile()
            
            if self.getAllItems().isEmpty {
                self.createSampleData()
                self.loadItemsFromJSONFile()
            }
            
            // Сообщим UI, что данные обновились
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
                completion()
            }
        }
    }
    
    
    deinit {
        trackDeallocation() // для анализа на memory leaks
    }
    
}

extension AppFileManager: DataProvider{
    
    func getAllItems() -> [IncomeEntry] {
        return allItems
    }
    
    func addNewItem(_ item: IncomeEntry) {
        allItems.append(item)
        saveItems()
//        print(allItems)
    }
    
    func deleteItem (withId id: UUID){
        allItems.removeAll { $0.id == id }
        saveItems()
    }
    
    func updateItem(for id: UUID? = nil, for ids: [UUID]? = nil, newCar: String? = nil, newPrice: Double? = nil, newDate: Date? = nil, newStatus: Bool? = nil, newSource: IncomeSource? = nil) {
        
        if let singleId = id {
//            print("change singleId")
            // Обновляем один элемент
            guard let index = allItems.firstIndex(where: { $0.id == singleId }) else { return }
            updateItemAt(index: index, newCar: newCar, newPrice: newPrice, newDate: newDate, newStatus: newStatus, newSource: newSource)
            
        } else if let multipleIds = ids {
            // Обновляем несколько элементов
//            print("change multipleIds")
            for itemId in multipleIds {
                guard let index = allItems.firstIndex(where: { $0.id == itemId }) else { 
                    continue // ❌ Пропускаем не найденный ID, продолжаем со следующим
                }
                updateItemAt(index: index, newCar: newCar, newPrice: newPrice, newDate: newDate, newStatus: newStatus, newSource: newSource)
            }
        }
        
        // Сохраняем и уведомляем один раз в конце
        saveItems()
    }
    
    
    func saveItems() {
        ensureFoldersExist() // ✅ создаём папки, если их нет
        // Отменяем предыдущее сохранение
//        saveWorkItem?.cancel()
        
        saveWorkItem = DispatchWorkItem { [weak self] in
            self?.performSave()
        }
        
        // Задержка для группировки частых изменений
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: saveWorkItem!)
    }

}
