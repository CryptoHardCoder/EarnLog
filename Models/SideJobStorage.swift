//
//  SideJobStorage.swift
//  EarnLog
//
//  Created by M3 pro on 02/08/2025.
//

import Foundation

class SideJobStorage: MemoryTrackable{
    
    static let shared = SideJobStorage()
    
    private let key = "customSideJobs"
    
    private var excempleSideJobs: [IncomeSource.SideJob] = []
    
    private var allCustomJobs = [IncomeSource.SideJob]()
    
    private init() {
        if loadAllCustomJobs().isEmpty {
//            createExampleJobsIfNeeded()
        }
        trackCreation() //для анализа на memory leaks
    }
    
    func createExampleJobsIfNeeded() {
        let exampleJobs = [
            IncomeSource.SideJob(id: UUID(uuidString: "5006324B-56D3-401A-8234-BC2064F90B1F")!, name: "Prodetail", isCustom: true, isActive: true),
            IncomeSource.SideJob(id: UUID(uuidString: "DD36911A-FACA-4E7E-9D26-FDF9808E1F14")!, name: "Fenix", isCustom: true, isActive: true),
            IncomeSource.SideJob(id: UUID(uuidString: "A8F7B3E4-4C91-4424-80D4-2C15B0A6B9F9")!, name: "Warszawa26", isCustom: true, isActive: true)
        ]
        saveCustomJobs(jobs: exampleJobs)
    }
    
    func loadActiveCustomJobs() -> [IncomeSource.SideJob] {
        return loadAllCustomJobs().filter { $0.isActive }
    }
    
    func loadAllCustomJobs() -> [IncomeSource.SideJob]{
        guard let customSideJobs = UserDefaults.standard.data(forKey: key) else { return []}
        do {
            return try JSONDecoder().decode([IncomeSource.SideJob].self, from: customSideJobs)
        } catch {
            print("⚠️ Ошибка загрузки, пробуем миграцию в новый формат: \(error)")
            
            // Попробуем загрузить как старую структуру без isActive
            do{
                return try migrateOldFormat(from: customSideJobs)
            } catch {
                return []
            }
        }
    }
    
    private func migrateOldFormat(from data: Data) throws -> [IncomeSource.SideJob] {
        // Структура для старых данных
        struct OldSideJob: Codable {
            let id: UUID
            var name: String
            let isCustom: Bool
        }
        
        do {
            let oldJobs = try JSONDecoder().decode([OldSideJob].self, from: data)
            
            // Конвертируем в новый формат
            let newJobs = oldJobs.map { oldJob in
                IncomeSource.SideJob(
                    id: oldJob.id,
                    name: oldJob.name,
                    isCustom: oldJob.isCustom,
                    isActive: true, // ✅ Исправлено: должно быть true
                )
            }
            
            // Сразу сохраняем в новом формате
            saveCustomJobs(jobs: newJobs)
            print("✅ Миграция завершена успешно")
            
            return newJobs
        } catch {
            print("❌ Критическая ошибка миграции: \(error)")
            throw error
        }
    }
    
    // ✅ ЕДИНСТВЕННОЕ место для отправки уведомлений
    func saveCustomJobs(jobs: [IncomeSource.SideJob]) {
        do {
            let data = try JSONEncoder().encode(jobs)
            UserDefaults.standard.set(data, forKey: key)
//            print("📡 saveCustomJobs отправляет уведомление")
            NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
        } catch {
            print("❌ Ошибка сохранения подработок: \(error)")
        }
    }
    
    // ✅ Исправлено: используем saveCustomJobs
    func saveNewCustomJob(sideJobName: String) {
        let newSideJob = IncomeSource.SideJob(id: UUID(), name: sideJobName, isCustom: true, isActive: true)
        var allSideJobs = loadAllCustomJobs()
        allSideJobs.append(newSideJob)
        
        // ✅ Используем единый метод сохранения
        saveCustomJobs(jobs: allSideJobs)
    }
    
    // ✅ Исправлено: работаем со ВСЕМИ подработками
    func editCustomJob(newName: String, editingJobId: UUID) {
        var allSideJobs = loadAllCustomJobs() // ✅ Загружаем ВСЕ (включая неактивные)
        
        if let index = allSideJobs.firstIndex(where: { $0.id == editingJobId }) {
            allSideJobs[index].name = newName
            saveCustomJobs(jobs: allSideJobs)
//            AppFileManager.shared.updateSideJobInfo(sideJobId: id)
            AppFileManager.shared.updateSideJobInfo(updatedJob: allSideJobs[index])
//            print("✅ Изменено название подработки: \(newName)")
        } else {
            print("❌ Подработка с id \(editingJobId) не найдена")
            return
        }
        
        // ✅ Используем единый метод сохранения
        saveCustomJobs(jobs: allSideJobs)
    }
    
    // ✅ Исправлено: работаем со ВСЕМИ подработками
    func deleteCustomJob(id: UUID) {
        var allSideJobs = loadAllCustomJobs() // ✅ Загружаем ВСЕ
        
        if let index = allSideJobs.firstIndex(where: { $0.id == id }) {
            allSideJobs[index].isActive = false
            saveCustomJobs(jobs: allSideJobs)
//            AppFileManager.shared.updateSideJobInfo(sideJobId: id)
            AppFileManager.shared.updateSideJobInfo(updatedJob: allSideJobs[index])
//            print(allSideJobs)
//            print("✅ Подработка '\(allSideJobs[index].name)' помечена как неактивная")
//            print(allSideJobs)
        } else {
            print("❌ Подработка с id \(id) не найдена")
            return
        }
        
        // ✅ Используем единый метод сохранения
        
    }
    
    // ✅ Дополнительный метод для безопасного получения подработки
    func getJobById(_ id: UUID) -> IncomeSource.SideJob? {
        return loadAllCustomJobs().first(where: { $0.id == id })
    }
    
    func getJobByIdOrPlaceholder(_ id: UUID) -> IncomeSource.SideJob {
        if let job = getJobById(id) {
            return job
        } else {
            return IncomeSource.SideJob(
                id: id,
                name: "Удаленная подработка",
                isCustom: true,
                isActive: false
            )
        }
    }
    
    deinit {
        trackDeallocation() // для анализа на memory leaks
    }
}
