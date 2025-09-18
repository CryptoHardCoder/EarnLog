/*
 //TODO: Прочитать и понять что здесь происходить это для премиум сделано
 import Foundation
 import UIKit
 
 // MARK: - Уведомления для Premium статуса
 extension NSNotification.Name {
 static let premiumStatusChanged = NSNotification.Name("premiumStatusChanged")
 static let archiveError = NSNotification.Name("archiveError")
 static let dataMigrationStarted = NSNotification.Name("dataMigrationStarted")
 static let dataMigrationCompleted = NSNotification.Name("dataMigrationCompleted")
 }
 
 // MARK: - Улучшенный PremiumManager
 final class PremiumManager {
 static let shared = PremiumManager()
 
 private let premiumKey = "isPremium"
 
 private init() {}
 
 var isPremium: Bool {
 UserDefaults.standard.bool(forKey: premiumKey)
 }
 
 /// Универсальный метод для установки Premium статуса
 func setPremiumStatus(_ isActive: Bool) {
 let previousStatus = isPremium
 UserDefaults.standard.set(isActive, forKey: premiumKey)
 
 // Уведомляем только если статус действительно изменился
 if previousStatus != isActive {
 print("🔄 Premium статус изменился: \(isActive ? "активирован" : "деактивирован")")
 NotificationCenter.default.post(name: .premiumStatusChanged, object: nil)
 }
 }
 
 /// Активирует Premium (обертка для удобства)
 func activatePremium() {
 setPremiumStatus(true)
 }
 
 /// Деактивирует Premium (обертка для удобства)
 func deactivatePremium() {
 setPremiumStatus(false)
 }
 
 /// Проверяет доступность iCloud
 func isICloudAvailable() -> Bool {
 if let _ = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
 return true
 }
 return false
 }
 }
 
 import Foundation
 import UIKit
 
 class AppFileManager2 {
 
 static let shared = AppFileManager2()
 
 private let jsonFileName = "allItems.json"
 private let myApplicationSupportFilesFolder = "My Application Support Files"
 private let exportedFilesFolderName = "Exported Files"
 
 let fileManager = FileManager.default
 let hiddenFolder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
 
 // MARK: - Computed Property для динамического переключения папок
 var userAccessibleFolder: URL {
 if PremiumManager.shared.isPremium && PremiumManager.shared.isICloudAvailable(),
 let iCloudFolder = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
 .appending(path: exportedFilesFolderName) {
 print("📁 Используем хранилище iCloud")
 return iCloudFolder
 } else {
 let localFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
 print("📁 Используем локальное хранилище")
 return localFolder
 }
 }
 
 var myApplicationSupportFilesFolderURL: URL {
 return hiddenFolder.appending(path: myApplicationSupportFilesFolder)
 }
 
 private var exportedFilesFolderURL: URL {
 return userAccessibleFolder.appending(path: exportedFilesFolderName)
 }
 
 private var jsonFileURL: URL {
 return myApplicationSupportFilesFolderURL.appending(path: jsonFileName)
 }
 
 var allItems: [IncomeEntry] = []
 var updatedAllitems = [IncomeEntry]()
 var partTimeWorkItems: [IncomeEntry] = []
 var basicWorkItems: [IncomeEntry] = []
 
 let defaultSources: [IncomeSource] = [.mainJob]
 
 var customSources: [IncomeSource.SideJob] {
 SideJobStorage.shared.loadAllCustomJobs()
 }
 
 var sources: [IncomeSource] {
 return defaultSources + customSources.map { .sideJob($0) }
 }
 
 // MARK: - Инициализация с подпиской на изменения Premium статуса
 init() {
 setupPremiumStatusObserver()
 }
 
 // MARK: - Подписка на изменения Premium статуса
 private func setupPremiumStatusObserver() {
 NotificationCenter.default.addObserver(
 self,
 selector: #selector(premiumStatusChanged),
 name: .premiumStatusChanged,
 object: nil
 )
 }
 
 // MARK: - Обработка изменения Premium статуса
 @objc private func premiumStatusChanged() {
 print("🔄 Получено уведомление об изменении Premium статуса")
 
 // Запускаем миграцию данных в фоновом потоке
 DispatchQueue.global(qos: .utility).async { [weak self] in
 self?.migrateDataForPremiumChange()
 }
 }
 
 // MARK: - Миграция данных при смене Premium статуса
 private func migrateDataForPremiumChange() {
 print("🚀 Начинаем миграцию данных...")
 
 // Уведомляем о начале миграции
 DispatchQueue.main.async {
 NotificationCenter.default.post(name: .dataMigrationStarted, object: nil)
 }
 
 do {
 let oldFolderURL: URL
 let newFolderURL: URL
 
 if PremiumManager.shared.isPremium {
 // Переносим из локального в iCloud
 oldFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
 .appending(path: exportedFilesFolderName)
 newFolderURL = userAccessibleFolder.appending(path: exportedFilesFolderName)
 print("📤 Переносим данные в iCloud")
 } else {
 // Переносим из iCloud в локальное хранилище
 if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
 oldFolderURL = iCloudURL.appending(path: exportedFilesFolderName)
 newFolderURL = userAccessibleFolder.appending(path: exportedFilesFolderName)
 print("📥 Переносим данные из iCloud в локальное хранилище")
 } else {
 // Если iCloud недоступен, просто завершаем
 DispatchQueue.main.async {
 NotificationCenter.default.post(name: .dataMigrationCompleted, object: nil)
 }
 return
 }
 }
 
 // Проверяем существование старой папки
 guard fileManager.fileExists(atPath: oldFolderURL.path) else {
 print("📂 Старая папка не найдена, миграция не требуется")
 DispatchQueue.main.async {
 NotificationCenter.default.post(name: .dataMigrationCompleted, object: nil)
 }
 return
 }
 
 // Создаем новую папку если её нет
 if !fileManager.fileExists(atPath: newFolderURL.path) {
 try fileManager.createDirectory(at: newFolderURL, withIntermediateDirectories: true)
 }
 
 // Получаем список файлов для переноса
 let files = try fileManager.contentsOfDirectory(atPath: oldFolderURL.path)
 
 // Переносим каждый файл
 for fileName in files {
 let oldFileURL = oldFolderURL.appending(path: fileName)
 let newFileURL = newFolderURL.appending(path: fileName)
 
 // Удаляем файл в новом месте если он существует
 if fileManager.fileExists(atPath: newFileURL.path) {
 try fileManager.removeItem(at: newFileURL)
 }
 
 // Копируем файл
 try fileManager.copyItem(at: oldFileURL, to: newFileURL)
 print("📄 Перенесен файл: \(fileName)")
 }
 
 print("✅ Миграция данных завершена успешно")
 
 } catch {
 print("❌ Ошибка миграции данных: \(error)")
 
 // Уведомляем об ошибке
 DispatchQueue.main.async {
 NotificationCenter.default.post(
 name: .archiveError,
 object: nil,
 userInfo: ["error": "Ошибка миграции данных: \(error.localizedDescription)"]
 )
 }
 }
 
 // Уведомляем о завершении миграции
 DispatchQueue.main.async {
 NotificationCenter.default.post(name: .dataMigrationCompleted, object: nil)
 }
 }
 
 // MARK: - Улучшенная обработка ошибок в архивации
 func archiveCurrentDataToCSV(for year: Int, month: Int) {
 DispatchQueue.global(qos: .utility).async { [weak self] in
 guard let self = self else { return }
 
 print("📦 Начинаем архивацию в фоновом потоке за \(month)/\(year)")
 
 // Убеждаемся что папка существует
 self.ensureCSVArchivesFolderExists()
 
 let monthName = self.getMonthName(month)
 let csvFileName = "archive_\(monthName)_\(year).csv"
 let csvFileURL = self.csvArchivesFolderURL.appendingPathComponent(csvFileName)
 
 // Создаем копию данных для безопасной работы в фоне
 let itemsToArchive = self.allItems.filter { item in
 let calendar = Calendar.current
 let itemMonth = calendar.component(.month, from: item.date)
 let itemYear  = calendar.component(.year, from: item.date)
 return month == itemMonth && year == itemYear
 }
 let itemsCount = itemsToArchive.count
 
 print("📦 Архивируем \(itemsCount) записей...")
 
 // Создаем CSV контент в фоне
 let csvContent = self.createCSVContent(from: itemsToArchive, monthName: monthName, year: year)
 
 do {
 // Сохраняем CSV файл
 try csvContent.write(to: csvFileURL, atomically: true, encoding: .utf8)
 print("💾 CSV архив сохранен в фоне: \(csvFileName)")
 
 // Создаем метаданные архива
 let metadata = ArchiveMetadata(
 year: year,
 month: month,
 itemsCount: itemsCount,
 csvFileName: csvFileName,
 createdAt: Date()
 )
 self.saveArchiveMetadata(metadata)
 
 } catch {
 // Улучшенная обработка ошибок
 DispatchQueue.main.async {
 print("❌ Ошибка сохранения CSV архива: \(error)")
 
 // Детальное уведомление об ошибке
 let errorInfo: [String: Any] = [
 "error": error.localizedDescription,
 "operation": "CSV Archive",
 "year": year,
 "month": month,
 "fileName": csvFileName
 ]
 
 NotificationCenter.default.post(
 name: .archiveError,
 object: nil,
 userInfo: errorInfo
 )
 }
 }
 }
 }
 
 // MARK: - Остальные методы без изменений
 func getAllItems() -> [IncomeEntry] {
 return allItems
 }
 
 private func chekCustomSources(){
 for i in 0..<allItems.count {
 if case let .sideJob(job) = allItems[i].source,
 let sideJob = customSources.first(where: { $0.id == job.id }),
 job != sideJob  {
 allItems[i].source = .sideJob(sideJob)
 }
 }
 }
 
 // Добавьте здесь все остальные ваши методы...
 // (addNewItem, deleteItem, updateItem, etc.)
 
 deinit {
 NotificationCenter.default.removeObserver(self)
 }
 }
 
 
 
 // MARK: - Обработка всех уведомлений в ViewController или другом классе

 class MainViewController: UIViewController {
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setupNotificationObservers()
     }
     
     // MARK: - Подписка на все уведомления
     private func setupNotificationObservers() {
         // Premium статус изменился
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(premiumStatusChanged),
             name: .premiumStatusChanged,
             object: nil
         )
         
         // Ошибка архивации
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(handleArchiveError(_:)),
             name: .archiveError,
             object: nil
         )
         
         // Миграция данных началась
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(dataMigrationStarted),
             name: .dataMigrationStarted,
             object: nil
         )
         
         // Миграция данных завершена
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(dataMigrationCompleted),
             name: .dataMigrationCompleted,
             object: nil
         )
     }
     
     // MARK: - Обработчики уведомлений
     
     @objc private func premiumStatusChanged() {
         print("🔄 Premium статус изменился")
         
         // Обновляем UI в зависимости от статуса
         DispatchQueue.main.async { [weak self] in
             if PremiumManager.shared.isPremium {
                 self?.showPremiumFeatures()
                 self?.showAlert(title: "Premium активирован!", 
                                message: "Теперь ваши данные будут синхронизироваться с iCloud")
             } else {
                 self?.hidePremiumFeatures()
                 self?.showAlert(title: "Premium деактивирован", 
                                message: "Данные перенесены в локальное хранилище")
             }
         }
     }
     
     @objc private func handleArchiveError(_ notification: Notification) {
         print("❌ Получена ошибка архивации")
         
         // Извлекаем информацию об ошибке
         guard let userInfo = notification.userInfo,
               let errorMessage = userInfo["error"] as? String else {
             return
         }
         
         let operation = userInfo["operation"] as? String ?? "Неизвестная операция"
         let fileName = userInfo["fileName"] as? String ?? "Неизвестный файл"
         
         // Показываем пользователю ошибку
         DispatchQueue.main.async { [weak self] in
             self?.showAlert(
                 title: "Ошибка архивации",
                 message: """
                 Операция: \(operation)
                 Файл: \(fileName)
                 Ошибка: \(errorMessage)
                 
                 Попробуйте повторить операцию позже.
                 """
             )
         }
     }
     
     @objc private func dataMigrationStarted() {
         print("🚀 Миграция данных началась")
         
         // Показываем индикатор загрузки
         DispatchQueue.main.async { [weak self] in
             self?.showLoadingIndicator(message: "Переносим данные...")
             
             // Блокируем взаимодействие с UI во время миграции
             self?.view.isUserInteractionEnabled = false
         }
     }
     
     @objc private func dataMigrationCompleted() {
         print("✅ Миграция данных завершена")
         
         // Скрываем индикатор загрузки
         DispatchQueue.main.async { [weak self] in
             self?.hideLoadingIndicator()
             
             // Разблокируем взаимодействие с UI
             self?.view.isUserInteractionEnabled = true
             
             // Обновляем данные в таблице/коллекции
             self?.refreshDataDisplay()
             
             // Показываем уведомление об успешной миграции
             self?.showAlert(
                 title: "Миграция завершена", 
                 message: "Данные успешно перенесены"
             )
         }
     }
     
     // MARK: - Вспомогательные методы для UI
     
     private func showPremiumFeatures() {
         // Показать Premium функции (например, кнопку iCloud синхронизации)
         print("🎉 Показываем Premium функции")
     }
     
     private func hidePremiumFeatures() {
         // Скрыть Premium функции
         print("📱 Скрываем Premium функции")
     }
     
     private func showLoadingIndicator(message: String) {
         // Показать индикатор загрузки с сообщением
         print("⏳ Показываем загрузку: \(message)")
         
         // Например:
         // let alert = UIAlertController(title: "Подождите", message: message, preferredStyle: .alert)
         // present(alert, animated: true)
     }
     
     private func hideLoadingIndicator() {
         // Скрыть индикатор загрузки
         print("✅ Скрываем загрузку")
         
         // Например:
         // dismiss(animated: true)
     }
     
     private func refreshDataDisplay() {
         // Обновить отображение данных
         print("🔄 Обновляем отображение данных")
         
         // Например:
         // tableView.reloadData()
         // collectionView.reloadData()
     }
     
     private func showAlert(title: String, message: String) {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "ОК", style: .default))
         present(alert, animated: true)
     }
     
     // MARK: - Очистка
     deinit {
         NotificationCenter.default.removeObserver(self)
     }
 }

 // MARK: - Альтернативный вариант - отдельный класс-менеджер уведомлений
 class NotificationManager {
     static let shared = NotificationManager()
     
     private init() {
         setupObservers()
     }
     
     private func setupObservers() {
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(handleArchiveError(_:)),
             name: .archiveError,
             object: nil
         )
         
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(handleMigrationStart),
             name: .dataMigrationStarted,
             object: nil
         )
         
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(handleMigrationComplete),
             name: .dataMigrationCompleted,
             object: nil
         )
     }
     
     @objc private func handleArchiveError(_ notification: Notification) {
         // Логирование ошибок для аналитики
         if let userInfo = notification.userInfo,
            let error = userInfo["error"] as? String {
             print("📊 Логируем ошибку для аналитики: \(error)")
             
             // Здесь можно отправить в Firebase Analytics, Crashlytics и т.д.
             // Analytics.logEvent("archive_error", parameters: userInfo)
         }
     }
     
     @objc private func handleMigrationStart() {
         print("📊 Логируем начало миграции")
         // Analytics.logEvent("data_migration_started")
     }
     
     @objc private func handleMigrationComplete() {
         print("📊 Логируем завершение миграции")
         // Analytics.logEvent("data_migration_completed")
     }
 }
 
 Отличный вопрос! В текущей реализации миграция будет **повторяться при каждом изменении Premium статуса**, даже если iCloud недоступен.

 ## Проблема:
 ```swift
 // Если iCloud недоступен, просто завершаем
 DispatchQueue.main.async {
     NotificationCenter.default.post(name: .dataMigrationCompleted, object: nil)
 }
 return
 ```

 Здесь мы просто **делаем вид**, что миграция завершена, но фактически ничего не мигрируем. При следующем изменении Premium статуса попытка повторится.

 ## Решение - добавить отслеживание состояния:Теперь **миграция умная**! Вот что изменилось:
 // MARK: - Состояния миграции
 enum MigrationState {
     case notNeeded        // Миграция не нужна
     case pending          // Ожидает выполнения
     case inProgress       // Выполняется
     case completed        // Завершена успешно
     case failedICloudUnavailable // Не удалась - iCloud недоступен
     case failedError      // Не удалась - другая ошибка
 }

 // MARK: - Менеджер состояния миграции
 class MigrationStateManager {
     static let shared = MigrationStateManager()
     
     private let lastMigrationStatusKey = "lastMigrationStatus"
     private let lastMigrationPremiumStatusKey = "lastMigrationPremiumStatus" 
     
     private init() {}
     
     // Сохраняем состояние последней миграции
     func setLastMigrationState(_ state: MigrationState, forPremiumStatus isPremium: Bool) {
         UserDefaults.standard.set(state.rawValue, forKey: lastMigrationStatusKey)
         UserDefaults.standard.set(isPremium, forKey: lastMigrationPremiumStatusKey)
     }
     
     // Получаем состояние последней миграции
     func getLastMigrationState() -> (state: MigrationState, premiumStatus: Bool) {
         let stateRaw = UserDefaults.standard.string(forKey: lastMigrationStatusKey) ?? ""
         let state = MigrationState(rawValue: stateRaw) ?? .notNeeded
         let premiumStatus = UserDefaults.standard.bool(forKey: lastMigrationPremiumStatusKey)
         
         return (state, premiumStatus)
     }
     
     // Проверяем нужна ли миграция
     func isMigrationNeeded() -> Bool {
         let currentPremiumStatus = PremiumManager.shared.isPremium
         let (lastState, lastPremiumStatus) = getLastMigrationState()
         
         // Если статус не изменился - миграция не нужна
         if currentPremiumStatus == lastPremiumStatus {
             return false
         }
         
         // Если предыдущая миграция не удалась из-за недоступности iCloud
         // и мы все еще пытаемся активировать Premium - проверяем iCloud снова
         if lastState == .failedICloudUnavailable && currentPremiumStatus == true {
             return PremiumManager.shared.isICloudAvailable()
         }
         
         return true
     }
     
     // Очищаем состояние (например, при принудительной миграции)
     func resetMigrationState() {
         UserDefaults.standard.removeObject(forKey: lastMigrationStatusKey)
         UserDefaults.standard.removeObject(forKey: lastMigrationPremiumStatusKey)
     }
 }

 extension MigrationState: RawRepresentable {
     typealias RawValue = String
     
     init?(rawValue: String) {
         switch rawValue {
         case "notNeeded": self = .notNeeded
         case "pending": self = .pending
         case "inProgress": self = .inProgress
         case "completed": self = .completed
         case "failedICloudUnavailable": self = .failedICloudUnavailable
         case "failedError": self = .failedError
         default: return nil
         }
     }
     
     var rawValue: String {
         switch self {
         case .notNeeded: return "notNeeded"
         case .pending: return "pending"
         case .inProgress: return "inProgress"
         case .completed: return "completed"
         case .failedICloudUnavailable: return "failedICloudUnavailable"
         case .failedError: return "failedError"
         }
     }
 }

 // MARK: - Улучшенная миграция в AppFileManager
 extension AppFileManager {
     
     // Обработка изменения Premium статуса с проверкой состояния
     @objc private func premiumStatusChanged() {
         print("🔄 Получено уведомление об изменении Premium статуса")
         
         // Проверяем нужна ли миграция
         guard MigrationStateManager.shared.isMigrationNeeded() else {
             print("ℹ️ Миграция не требуется")
             return
         }
         
         // Запускаем миграцию данных в фоновом потоке
         DispatchQueue.global(qos: .utility).async { [weak self] in
             self?.migrateDataForPremiumChange()
         }
     }
     
     // Улучшенная миграция с отслеживанием состояния
     private func migrateDataForPremiumChange() {
         print("🚀 Начинаем миграцию данных...")
         
         let currentPremiumStatus = PremiumManager.shared.isPremium
         
         // Устанавливаем состояние "в процессе"
         MigrationStateManager.shared.setLastMigrationState(.inProgress, forPremiumStatus: currentPremiumStatus)
         
         // Уведомляем о начале миграции
         DispatchQueue.main.async {
             NotificationCenter.default.post(name: .dataMigrationStarted, object: nil)
         }
         
         // Специальная обработка для Premium когда iCloud недоступен
         if currentPremiumStatus && !PremiumManager.shared.isICloudAvailable() {
             print("⚠️ Premium активен, но iCloud недоступен")
             
             // Сохраняем состояние неудачи
             MigrationStateManager.shared.setLastMigrationState(.failedICloudUnavailable, forPremiumStatus: currentPremiumStatus)
             
             // Уведомляем пользователя о проблеме
             DispatchQueue.main.async {
                 let errorInfo: [String: Any] = [
                     "error": "iCloud недоступен. Включите iCloud Drive в настройках устройства для использования Premium функций.",
                     "operation": "Premium Activation",
                     "canRetry": true
                 ]
                 
                 NotificationCenter.default.post(
                     name: .archiveError,
                     object: nil,
                     userInfo: errorInfo
                 )
                 
                 NotificationCenter.default.post(name: .dataMigrationCompleted, object: nil)
             }
             return
         }
         
         do {
             let oldFolderURL: URL
             let newFolderURL: URL
             
             if currentPremiumStatus {
                 // Переносим из локального в iCloud
                 oldFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                     .appending(path: exportedFilesFolderName)
                 newFolderURL = userAccessibleFolder.appending(path: exportedFilesFolderName)
                 print("📤 Переносим данные в iCloud")
             } else {
                 // Переносим из iCloud в локальное хранилище
                 if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
                     oldFolderURL = iCloudURL.appending(path: exportedFilesFolderName)
                     newFolderURL = userAccessibleFolder.appending(path: exportedFilesFolderName)
                     print("📥 Переносим данные из iCloud в локальное хранилище")
                 } else {
                     // Это не должно происходить при деактивации Premium, но на всякий случай
                     MigrationStateManager.shared.setLastMigrationState(.completed, forPremiumStatus: currentPremiumStatus)
                     DispatchQueue.main.async {
                         NotificationCenter.default.post(name: .dataMigrationCompleted, object: nil)
                     }
                     return
                 }
             }
             
             // Проверяем существование старой папки
             guard fileManager.fileExists(atPath: oldFolderURL.path) else {
                 print("📂 Старая папка не найдена, миграция считается завершенной")
                 MigrationStateManager.shared.setLastMigrationState(.completed, forPremiumStatus: currentPremiumStatus)
                 DispatchQueue.main.async {
                     NotificationCenter.default.post(name: .dataMigrationCompleted, object: nil)
                 }
                 return
             }
             
             // Создаем новую папку если её нет
             if !fileManager.fileExists(atPath: newFolderURL.path) {
                 try fileManager.createDirectory(at: newFolderURL, withIntermediateDirectories: true)
             }
             
             // Получаем список файлов для переноса
             let files = try fileManager.contentsOfDirectory(atPath: oldFolderURL.path)
             
             // Переносим каждый файл
             for fileName in files {
                 let oldFileURL = oldFolderURL.appending(path: fileName)
                 let newFileURL = newFolderURL.appending(path: fileName)
                 
                 // Удаляем файл в новом месте если он существует
                 if fileManager.fileExists(atPath: newFileURL.path) {
                     try fileManager.removeItem(at: newFileURL)
                 }
                 
                 // Копируем файл
                 try fileManager.copyItem(at: oldFileURL, to: newFileURL)
                 print("📄 Перенесен файл: \(fileName)")
             }
             
             // Устанавливаем состояние "завершено"
             MigrationStateManager.shared.setLastMigrationState(.completed, forPremiumStatus: currentPremiumStatus)
             print("✅ Миграция данных завершена успешно")
             
         } catch {
             print("❌ Ошибка миграции данных: \(error)")
             
             // Сохраняем состояние ошибки
             MigrationStateManager.shared.setLastMigrationState(.failedError, forPremiumStatus: currentPremiumStatus)
             
             // Уведомляем об ошибке
             DispatchQueue.main.async {
                 let errorInfo: [String: Any] = [
                     "error": "Ошибка миграции данных: \(error.localizedDescription)",
                     "operation": "Data Migration",
                     "canRetry": true
                 ]
                 
                 NotificationCenter.default.post(
                     name: .archiveError,
                     object: nil,
                     userInfo: errorInfo
                 )
             }
         }
         
         // Уведомляем о завершении миграции
         DispatchQueue.main.async {
             NotificationCenter.default.post(name: .dataMigrationCompleted, object: nil)
         }
     }
     
     // MARK: - Дополнительные методы
     
     /// Принудительная повторная миграция (например, по кнопке "Повторить")
     func retryMigration() {
         MigrationStateManager.shared.resetMigrationState()
         premiumStatusChanged()
     }
     
     /// Получение информации о состоянии миграции
     func getMigrationInfo() -> (needsAttention: Bool, message: String) {
         let (state, premiumStatus) = MigrationStateManager.shared.getLastMigrationState()
         
         switch state {
         case .failedICloudUnavailable:
             return (true, "iCloud недоступен. Включите iCloud Drive для использования Premium функций.")
         case .failedError:
             return (true, "Ошибка переноса данных. Попробуйте еще раз.")
         case .inProgress:
             return (true, "Идет перенос данных...")
         default:
             return (false, "")
         }
     }
 }
 ## **Отслеживание состояний:**
 - `completed` - миграция завершена успешно, **не повторится**
 - `failedICloudUnavailable` - не удалась из-за iCloud, **повторится только когда iCloud станет доступен**
 - `failedError` - не удалась из-за ошибки, **повторится при следующем изменении статуса**

 ## **Логика повторов:**
 1. **Premium → Premium** (без изменений) - миграция **НЕ запустится**
 2. **iCloud недоступен** - миграция **НЕ повторится до появления iCloud**  
 3. **Ошибка файловой системы** - миграция **повторится** при следующей попытке
 4. **Успешная миграция** - **НЕ повторится** пока статус не изменится

 ## **Дополнительные возможности:**
 ```swift
 // Проверить нужно ли показать предупреждение пользователю
 let (needsAttention, message) = AppFileManager.shared.getMigrationInfo()
 if needsAttention {
     showAlert(message: message)
 }

 // Принудительно повторить миграцию (кнопка "Повторить")
 AppFileManager.shared.retryMigration()
 ```

 **Итог:** Теперь система не будет бесконечно пытаться мигрировать при недоступности iCloud, но предложит пользователю включить iCloud Drive и позволит повторить попытку вручную.
 
 
 iCloud недоступен - миграция НЕ повторится до появления iCloud
 а как мы узнаем что появился icloud или интернет?
 
 
 Отличный вопрос! В текущей реализации мы **НЕ** отслеживаем появление iCloud автоматически. Вот варианты решения:
 import Foundation
 import Network
 import UIKit

 // MARK: - Мониторинг iCloud и интернета
 class iCloudMonitor {
     static let shared = iCloudMonitor()
     
     private var networkMonitor: NWPathMonitor?
     private var monitorQueue = DispatchQueue(label: "iCloudMonitor")
     
     // Уведомления
     static let iCloudBecameAvailable = NSNotification.Name("iCloudBecameAvailable")
     static let internetConnectionRestored = NSNotification.Name("internetConnectionRestored")
     
     private init() {
         startMonitoring()
     }
     
     // MARK: - Запуск мониторинга
     private func startMonitoring() {
         // 1. Мониторинг интернет соединения
         startNetworkMonitoring()
         
         // 2. Мониторинг изменений в настройках (когда пользователь включает iCloud)
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(appDidBecomeActive),
             name: UIApplication.didBecomeActiveNotification,
             object: nil
         )
         
         // 3. Мониторинг доступности iCloud через файловую систему
         startFileSystemMonitoring()
     }
     
     // MARK: - Мониторинг интернета
     private func startNetworkMonitoring() {
         networkMonitor = NWPathMonitor()
         
         networkMonitor?.pathUpdateHandler = { [weak self] path in
             if path.status == .satisfied {
                 print("🌐 Интернет соединение восстановлено")
                 self?.checkiCloudAfterNetworkRestore()
             } else {
                 print("🚫 Интернет соединение потеряно")
             }
         }
         
         networkMonitor?.start(queue: monitorQueue)
     }
     
     // MARK: - Проверка iCloud после восстановления интернета
     private func checkiCloudAfterNetworkRestore() {
         // Небольшая задержка, чтобы iCloud успел инициализироваться
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
             if PremiumManager.shared.isICloudAvailable() {
                 print("☁️ iCloud стал доступен после восстановления интернета")
                 NotificationCenter.default.post(name: Self.iCloudBecameAvailable, object: nil)
             }
         }
     }
     
     // MARK: - Проверка при возвращении в приложение
     @objc private func appDidBecomeActive() {
         // Проверяем iCloud когда пользователь возвращается в приложение
         // (возможно включил iCloud в настройках)
         checkiCloudAvailability()
     }
     
     // MARK: - Мониторинг файловой системы iCloud
     private func startFileSystemMonitoring() {
         // Периодическая проверка доступности iCloud (каждые 30 секунд)
         Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
             self?.checkiCloudAvailability()
         }
     }
     
     // MARK: - Проверка доступности iCloud
     private func checkiCloudAvailability() {
         let wasUnavailable = !PremiumManager.shared.isICloudAvailable()
         
         // Проверяем текущее состояние
         let isNowAvailable = checkiCloudStatus()
         
         // Если iCloud стал доступен
         if wasUnavailable && isNowAvailable {
             print("☁️ iCloud стал доступен!")
             NotificationCenter.default.post(name: Self.iCloudBecameAvailable, object: nil)
         }
     }
     
     // MARK: - Детальная проверка iCloud
     private func checkiCloudStatus() -> Bool {
         // 1. Основная проверка
         guard let _ = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
             return false
         }
         
         // 2. Проверка статуса аккаунта iCloud
         if #available(iOS 9.0, *) {
             let status = FileManager.default.ubiquityIdentityToken
             return status != nil
         }
         
         return true
     }
     
     // MARK: - Принудительная проверка
     func forceCheckiCloudAvailability() {
         checkiCloudAvailability()
     }
     
     deinit {
         networkMonitor?.cancel()
         NotificationCenter.default.removeObserver(self)
     }
 }

 // MARK: - Обновленный MigrationStateManager
 extension MigrationStateManager {
     
     /// Настройка мониторинга iCloud для автоматической миграции
     func setupiCloudMonitoring() {
         // Подписываемся на уведомление о появлении iCloud
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(iCloudBecameAvailable),
             name: iCloudMonitor.iCloudBecameAvailable,
             object: nil
         )
     }
     
     @objc private func iCloudBecameAvailable() {
         print("☁️ Получено уведомление о доступности iCloud")
         
         // Проверяем есть ли незавершенная миграция из-за недоступности iCloud
         let (lastState, _) = getLastMigrationState()
         
         if lastState == .failedICloudUnavailable {
             print("🔄 Повторяем миграцию после появления iCloud")
             
             // Запускаем миграцию заново
             DispatchQueue.main.async {
                 NotificationCenter.default.post(name: .premiumStatusChanged, object: nil)
             }
         }
     }
 }

 // MARK: - Обновленный AppFileManager
 extension AppFileManager {
     
     /// Инициализация мониторинга (вызвать в init)
     func setupiCloudMonitoring() {
         MigrationStateManager.shared.setupiCloudMonitoring()
         
         // Дополнительно можем подписаться на другие события
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(handleiCloudAvailable),
             name: iCloudMonitor.iCloudBecameAvailable,
             object: nil
         )
     }
     
     @objc private func handleiCloudAvailable() {
         print("📱 AppFileManager: iCloud стал доступен")
         
         // Можем обновить UI или выполнить другие действия
         DispatchQueue.main.async {
             NotificationCenter.default.post(
                 name: NSNotification.Name("iCloudStatusChanged"), 
                 object: nil,
                 userInfo: ["available": true]
             )
         }
     }
 }

 // MARK: - Методы для ViewController
 extension MainViewController {
     
     // Обработчик появления iCloud
     @objc private func iCloudBecameAvailable() {
         print("🎉 iCloud доступен! Обновляем UI")
         
         DispatchQueue.main.async { [weak self] in
             // Скрываем предупреждения о недоступности iCloud
             self?.hideNoiCloudWarning()
             
             // Показываем уведомление пользователю
             self?.showAlert(
                 title: "iCloud доступен!", 
                 message: "Теперь можно использовать Premium функции. Данные будут автоматически синхронизированы."
             )
             
             // Обновляем интерфейс
             self?.updatePremiumUI()
         }
     }
     
     // Показать кнопку "Проверить iCloud" при проблемах
     private func showManualCheckButton() {
         let checkButton = UIButton(type: .system)
         checkButton.setTitle("Проверить iCloud", for: .normal)
         checkButton.addTarget(self, action: #selector(manuallyCheckiCloud), for: .touchUpInside)
         // Добавить на экран
     }
     
     @objc private func manuallyCheckiCloud() {
         iCloudMonitor.shared.forceCheckiCloudAvailability()
         
         // Показать индикатор проверки
         showAlert(title: "Проверяем...", message: "Проверяем доступность iCloud")
     }
     
     private func hideNoiCloudWarning() {
         // Скрыть предупреждения UI
     }
     
     private func updatePremiumUI() {
         // Обновить интерфейс Premium функций
     }
 }

 // MARK: - Пример использования в SceneDelegate
 /*
 func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
     // ... ваш существующий код ...
     
     // Запускаем мониторинг iCloud
     _ = iCloudMonitor.shared
     AppFileManager.shared.setupiCloudMonitoring()
 }
 */
 
 Теперь система **автоматически** отслеживает появление iCloud тремя способами:

 ## **1. Мониторинг интернет-соединения** 🌐
 ```swift
 // Через NWPathMonitor - когда восстанавливается интернет
 // Через 2 секунды проверяет iCloud (время на инициализацию)
 ```

 ## **2. Мониторинг возврата в приложение** 📱  
 ```swift
 // Когда пользователь возвращается в приложение
 // (возможно включил iCloud в Настройках)
 UIApplication.didBecomeActiveNotification
 ```

 ## **3. Периодическая проверка** ⏰
 ```swift
 // Каждые 30 секунд проверяет доступность iCloud
 Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true)
 ```

 ## **Как это работает:**

 1. **iCloud недоступен** → миграция помечается как `failedICloudUnavailable`
 2. **Система мониторинга** отслеживает появление iCloud  
 3. **iCloud появился** → автоматически отправляется `premiumStatusChanged`
 4. **Миграция повторяется** автоматически

 ## **Дополнительно для пользователя:**

 ```swift
 // Кнопка "Проверить iCloud" для принудительной проверки
 @objc private func manuallyCheckiCloud() {
     iCloudMonitor.shared.forceCheckiCloudAvailability()
 }

 // Показать статус в UI
 let (needsAttention, message) = AppFileManager.shared.getMigrationInfo()
 if needsAttention {
     showAlert(message: message + "\n\nБудем автоматически проверять каждые 30 секунд.")
 }
 ```

 **Итог:** Система теперь **сама** найдет момент когда iCloud станет доступен и автоматически завершит миграцию без участия пользователя!
 */
