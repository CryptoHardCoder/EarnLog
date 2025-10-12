//
//  SideJobStorage.swift
//  EarnLog
//
//  Created by M3 pro on 02/08/2025.
//
import Foundation
import CoreData

class SideJobManagerImpl: SideJobManagerRepository, MemoryTrackable{
    
    let dataManager: CoreDataManagerRepository
    
    init(dataManager: CoreDataManagerRepository) {
        self.dataManager = dataManager
    }
    
    private func jobExists(with name: String) async throws -> Bool {
        let predicate = NSPredicate(format: "name ==[c] %@", name)
        let existing = try await dataManager.fetch(
            SideJobEntity.self,
            predicate: predicate,
            limit: 1
        )
        return !existing.isEmpty
    }
    
    
    func loadActiveJobs() async throws -> [SideJob] {
        let entities = try await dataManager.fetch(SideJobEntity.self)
        return entities
            .filter { $0.isActive }
            .map { $0.toSideJob() }
    }    
    
    func getAllJobs() async throws -> [SideJob] {
        try await dataManager.fetch(SideJobEntity.self)
            .map { $0.toSideJob() }
    }
    
    func saveNewJob(job: SideJob) async throws {
        if try await jobExists(with: job.name) {
            throw SideJobError.duplicateName(job.name)
        }
        _ = try await dataManager.create(SideJobEntity.self) { entity in
            entity.id = job.id
            entity.name = job.name
            entity.isCustom = job.isCustom
            entity.isActive = job.isActive
        }
    }
    
    func updateJob(id: UUID, newName: String) async throws {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name ==[c] %@", newName),
            NSPredicate(format: "id != %@", id as CVarArg)
        ])
         
        let duplicates = try await dataManager.fetch(
            SideJobEntity.self,
            predicate: predicate,
            limit: 1
        )
         
        if !duplicates.isEmpty {
            throw SideJobError.duplicateName(newName)
        }
        try await dataManager.update(id: id, type: SideJobEntity.self) { entity in
            entity.name = newName
        }
    }
    
    func deleteJob(id: UUID) async throws {
        try await dataManager.delete(id: id, type: SideJobEntity.self)
    }
    
    func getJobById(_ id: UUID) async throws -> SideJob? {
        let entity = try await dataManager.fetchByID(SideJobEntity.self, id: id)
        return entity?.toSideJob()
    }
    
    
    
    func createExampleJobsIfNeeded() -> [SideJob] {
        return [
            SideJob(id: UUID(uuidString: "5006324B-56D3-401A-8234-BC2064F90B1F")!, name: "Prodetail", isCustom: true, isActive: true),
            SideJob(id: UUID(uuidString: "DD36911A-FACA-4E7E-9D26-FDF9808E1F14")!, name: "Fenix", isCustom: true, isActive: true),
            SideJob(id: UUID(uuidString: "A8F7B3E4-4C91-4424-80D4-2C15B0A6B9F9")!, name: "Warszawa26", isCustom: true, isActive: true)
        ]
    }
    
}
    
    
    
    

    
    
//    private let key = "customSideJobs"
//    
//    private var excempleSideJobs: [SideJob] = []
//    
//    private var allCustomJobs = [SideJob]()
//    
//    private let appCoreServices = AppCoreServices.shared
//    
//    private init() {
//        if getAllJobs().isEmpty {
////            createExampleJobsIfNeeded()
//        }
//        trackCreation() //для анализа на memory leaks
//    }
//    
//    func createExampleJobsIfNeeded() {
//        let exampleJobs = [
//            SideJob(id: UUID(uuidString: "5006324B-56D3-401A-8234-BC2064F90B1F")!, name: "Prodetail", isCustom: true, isActive: true),
//            SideJob(id: UUID(uuidString: "DD36911A-FACA-4E7E-9D26-FDF9808E1F14")!, name: "Fenix", isCustom: true, isActive: true),
//            SideJob(id: UUID(uuidString: "A8F7B3E4-4C91-4424-80D4-2C15B0A6B9F9")!, name: "Warszawa26", isCustom: true, isActive: true)
//        ]
//        saveCustomJobs(jobs: exampleJobs)
//    }
//    
//    func loadActiveJobs() -> [SideJob] {
//        return getAllJobs().filter { $0.isActive }
//    }
//    
//    func getAllJobs() -> [SideJob]{
//        guard let customSideJobs = UserDefaults.standard.data(forKey: key) else { return []}
//        do {
//            return try JSONDecoder().decode([SideJob].self, from: customSideJobs)
//        } catch {
//            print("⚠️ Ошибка загрузки, пробуем миграцию в новый формат: \(error)")
//            
//            // Попробуем загрузить как старую структуру без isActive
//            do{
//                return try migrateOldFormat(from: customSideJobs)
//            } catch {
//                return []
//            }
//        }
//    }
//    
//    private func migrateOldFormat(from data: Data) throws -> [SideJob] {
//        // Структура для старых данных
//        struct OldSideJob: Codable {
//            let id: UUID
//            var name: String
//            let isCustom: Bool
//        }
//        
//        do {
//            let oldJobs = try JSONDecoder().decode([OldSideJob].self, from: data)
//            
//            // Конвертируем в новый формат
//            let newJobs = oldJobs.map { oldJob in
//                SideJob(
//                    id: oldJob.id,
//                    name: oldJob.name,
//                    isCustom: oldJob.isCustom,
//                    isActive: true, // ✅ Исправлено: должно быть true
//                )
//            }
//            
//            // Сразу сохраняем в новом формате
//            saveCustomJobs(jobs: newJobs)
//            print("✅ Миграция завершена успешно")
//            
//            return newJobs
//        } catch {
//            print("❌ Критическая ошибка миграции: \(error)")
//            throw error
//        }
//    }
//    
//    // ✅ ЕДИНСТВЕННОЕ место для отправки уведомлений
//    func saveCustomJobs(jobs: [SideJob]) {
//        do {
//            let data = try JSONEncoder().encode(jobs)
//            UserDefaults.standard.set(data, forKey: key)
////            print("📡 saveCustomJobs отправляет уведомление")
//            NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
//        } catch {
//            print("❌ Ошибка сохранения подработок: \(error)")
//        }
//    }
//    
//    // ✅ Исправлено: используем saveCustomJobs
//    func saveNewJob(name sideJobName: String) {
//        let newSideJob = SideJob(id: UUID(), name: sideJobName, isCustom: true, isActive: true)
//        var allSideJobs = getAllJobs()
//        allSideJobs.append(newSideJob)
//        
//        // ✅ Используем единый метод сохранения
//        saveCustomJobs(jobs: allSideJobs)
//    }
//    
//    // ✅ Исправлено: работаем со ВСЕМИ подработками
//    func updateJob(id: UUID, newName: String) {
//        var allSideJobs = getAllJobs() // ✅ Загружаем ВСЕ (включая неактивные)
//        
//        if let index = allSideJobs.firstIndex(where: { $0.id == id }) {
//            allSideJobs[index].name = newName
//            saveCustomJobs(jobs: allSideJobs)
////            AppFileManager.shared.updateSideJobInfo(sideJobId: id)
//                appCoreServices.appFileManager.updateSideJobInfo(updatedJob: allSideJobs[index])
////            print("✅ Изменено название подработки: \(newName)")
//        } else {
//            print("❌ Подработка с id \(id) не найдена")
//            return
//        }
//        
//        // ✅ Используем единый метод сохранения
//        saveCustomJobs(jobs: allSideJobs)
//    }
//    
//    // ✅ Исправлено: работаем со ВСЕМИ подработками
//    func deleteJob(id: UUID) {
//        var allSideJobs = getAllJobs() // ✅ Загружаем ВСЕ
//        
//        if let index = allSideJobs.firstIndex(where: { $0.id == id }) {
//            allSideJobs[index].isActive = false
//            saveCustomJobs(jobs: allSideJobs)
////            AppFileManager.shared.updateSideJobInfo(sideJobId: id)
//            appCoreServices.appFileManager.updateSideJobInfo(updatedJob: allSideJobs[index])
////            print(allSideJobs)
////            print("✅ Подработка '\(allSideJobs[index].name)' помечена как неактивная")
////            print(allSideJobs)
//        } else {
//            print("❌ Подработка с id \(id) не найдена")
//            return
//        }
//        
//        // ✅ Используем единый метод сохранения
//        
//    }
//    
//    // ✅ Дополнительный метод для безопасного получения подработки
//    func getJobById(_ id: UUID) -> SideJob? {
//        return getAllJobs().first(where: { $0.id == id })
//    }
//    
//    func getJobByIdOrPlaceholder(_ id: UUID) -> SideJob {
//        if let job = getJobById(id) {
//            return job
//        } else {
//            return SideJob(
//                id: id,
//                name: "Удаленная подработка",
//                isCustom: true,
//                isActive: false
//            )
//        }
//    }
//    
//    deinit {
//        trackDeallocation() // для анализа на memory leaks
//    }
//}

//
//static let shared = SideJobStorageImpl()
//
//private let key = "customSideJobs"
//
//private var excempleSideJobs: [SideJob] = []
//
//private var allCustomJobs = [SideJob]()
//
//private let appCoreServices = AppCoreServices.shared
//
//private init() {
//    if getAllJobs().isEmpty {
////            createExampleJobsIfNeeded()
//    }
//    trackCreation() //для анализа на memory leaks
//}
//
//func createExampleJobsIfNeeded() {
//    let exampleJobs = [
//        SideJob(id: UUID(uuidString: "5006324B-56D3-401A-8234-BC2064F90B1F")!, name: "Prodetail", isCustom: true, isActive: true),
//        SideJob(id: UUID(uuidString: "DD36911A-FACA-4E7E-9D26-FDF9808E1F14")!, name: "Fenix", isCustom: true, isActive: true),
//        SideJob(id: UUID(uuidString: "A8F7B3E4-4C91-4424-80D4-2C15B0A6B9F9")!, name: "Warszawa26", isCustom: true, isActive: true)
//    ]
//    saveCustomJobs(jobs: exampleJobs)
//}
//
//func loadActiveJobs() -> [SideJob] {
//    return getAllJobs().filter { $0.isActive }
//}
//
//func getAllJobs() -> [SideJob]{
//    guard let customSideJobs = UserDefaults.standard.data(forKey: key) else { return []}
//    do {
//        return try JSONDecoder().decode([SideJob].self, from: customSideJobs)
//    } catch {
//        print("⚠️ Ошибка загрузки, пробуем миграцию в новый формат: \(error)")
//        
//        // Попробуем загрузить как старую структуру без isActive
//        do{
//            return try migrateOldFormat(from: customSideJobs)
//        } catch {
//            return []
//        }
//    }
//}
//
//private func migrateOldFormat(from data: Data) throws -> [SideJob] {
//    // Структура для старых данных
//    struct OldSideJob: Codable {
//        let id: UUID
//        var name: String
//        let isCustom: Bool
//    }
//    
//    do {
//        let oldJobs = try JSONDecoder().decode([OldSideJob].self, from: data)
//        
//        // Конвертируем в новый формат
//        let newJobs = oldJobs.map { oldJob in
//            SideJob(
//                id: oldJob.id,
//                name: oldJob.name,
//                isCustom: oldJob.isCustom,
//                isActive: true, // ✅ Исправлено: должно быть true
//            )
//        }
//        
//        // Сразу сохраняем в новом формате
//        saveCustomJobs(jobs: newJobs)
//        print("✅ Миграция завершена успешно")
//        
//        return newJobs
//    } catch {
//        print("❌ Критическая ошибка миграции: \(error)")
//        throw error
//    }
//}
//
//// ✅ ЕДИНСТВЕННОЕ место для отправки уведомлений
//func saveCustomJobs(jobs: [SideJob]) {
//    do {
//        let data = try JSONEncoder().encode(jobs)
//        UserDefaults.standard.set(data, forKey: key)
////            print("📡 saveCustomJobs отправляет уведомление")
//        NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
//    } catch {
//        print("❌ Ошибка сохранения подработок: \(error)")
//    }
//}
//
//// ✅ Исправлено: используем saveCustomJobs
//func saveNewJob(name sideJobName: String) {
//    let newSideJob = SideJob(id: UUID(), name: sideJobName, isCustom: true, isActive: true)
//    var allSideJobs = getAllJobs()
//    allSideJobs.append(newSideJob)
//    
//    // ✅ Используем единый метод сохранения
//    saveCustomJobs(jobs: allSideJobs)
//}
//
//// ✅ Исправлено: работаем со ВСЕМИ подработками
//func updateJob(id: UUID, newName: String) {
//    var allSideJobs = getAllJobs() // ✅ Загружаем ВСЕ (включая неактивные)
//    
//    if let index = allSideJobs.firstIndex(where: { $0.id == id }) {
//        allSideJobs[index].name = newName
//        saveCustomJobs(jobs: allSideJobs)
////            AppFileManager.shared.updateSideJobInfo(sideJobId: id)
//            appCoreServices.appFileManager.updateSideJobInfo(updatedJob: allSideJobs[index])
////            print("✅ Изменено название подработки: \(newName)")
//    } else {
//        print("❌ Подработка с id \(id) не найдена")
//        return
//    }
//    
//    // ✅ Используем единый метод сохранения
//    saveCustomJobs(jobs: allSideJobs)
//}
//
//// ✅ Исправлено: работаем со ВСЕМИ подработками
//func deleteJob(id: UUID) {
//    var allSideJobs = getAllJobs() // ✅ Загружаем ВСЕ
//    
//    if let index = allSideJobs.firstIndex(where: { $0.id == id }) {
//        allSideJobs[index].isActive = false
//        saveCustomJobs(jobs: allSideJobs)
////            AppFileManager.shared.updateSideJobInfo(sideJobId: id)
//        appCoreServices.appFileManager.updateSideJobInfo(updatedJob: allSideJobs[index])
////            print(allSideJobs)
////            print("✅ Подработка '\(allSideJobs[index].name)' помечена как неактивная")
////            print(allSideJobs)
//    } else {
//        print("❌ Подработка с id \(id) не найдена")
//        return
//    }
//    
//    // ✅ Используем единый метод сохранения
//    
//}
//
//// ✅ Дополнительный метод для безопасного получения подработки
//func getJobById(_ id: UUID) -> SideJob? {
//    return getAllJobs().first(where: { $0.id == id })
//}
//
//func getJobByIdOrPlaceholder(_ id: UUID) -> SideJob {
//    if let job = getJobById(id) {
//        return job
//    } else {
//        return SideJob(
//            id: id,
//            name: "Удаленная подработка",
//            isCustom: true,
//            isActive: false
//        )
//    }
//}
//
//deinit {
//    trackDeallocation() // для анализа на memory leaks
//}
