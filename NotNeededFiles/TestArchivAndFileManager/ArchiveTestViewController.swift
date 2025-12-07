////
////  ArchiveTestManager.swift
////  JobData
////
////  Система тестирования функциональности архивации CarEntry
////
//
//import UIKit
//import Foundation
//
//// MARK: - Test Data Generator
///// Генератор тестовых данных для автомобилей
//struct TestDataGenerator {
//    
//    static let testCars = [
//        ("BMW X5", 45000.0, true),
//        ("Mercedes C200", 38000.0, false),
//        ("Audi A4", 35000.0, true),
//        ("Toyota Camry", 25000.0, true),
//        ("Honda Civic", 22000.0, false),
//        ("Volkswagen Golf", 20000.0, true),
//        ("Ford Focus", 18000.0, false),
//        ("Mazda CX-5", 28000.0, true),
//        ("Hyundai Elantra", 19000.0, true),
//        ("Kia Rio", 16000.0, false),
//        ("Nissan Qashqai", 27000.0, true),
//        ("Skoda Octavia", 24000.0, false),
//        ("Renault Duster", 21000.0, true),
//        ("Chevrolet Cruze", 20000.0, true),
//        ("Peugeot 308", 23000.0, false)
//    ]
//    
//    static func generateCarEntries(count: Int, for date: Date) -> [IncomeEntry] {
//        let calendar = Calendar.current
//        var entries: [IncomeEntry] = []
//        
//        // Получаем диапазон дней для указанной даты
//        let range = calendar.range(of: .day, in: .month, for: date) ?? 1..<32
//        let maxDay = min(range.upperBound - 1, calendar.component(.day, from: date))
//        
//        for i in 0..<count {
//            let testCar = testCars[i % testCars.count]
//            
//            // Случайная дата в пределах месяца
//            let randomDay = Int.random(in: 1...maxDay)
//            let randomHour = Int.random(in: 9...18)
//            let randomMinute = Int.random(in: 0...59)
//            
//            var dateComponents = calendar.dateComponents([.year, .month], from: date)
//            dateComponents.day = randomDay
//            dateComponents.hour = randomHour
//            dateComponents.minute = randomMinute
//            
//            let itemDate = calendar.date(from: dateComponents) ?? date
//            
//            // Вариация цены ±5000
//            let priceVariation = Double.random(in: -5000...5000)
//            let finalPrice = max(testCar.1 + priceVariation, 10000.0)
//            
//            let carEntry = IncomeEntry(
//                date: itemDate,
//                car: "\(testCar.0) #\(i+1)",
//                price: finalPrice,
//                isPaid: Bool.random(),
//                source: AppFileManager.shared.sources.randomElement() ?? .mainJob
//            )
//            
//            entries.append(carEntry)
//        }
//        
//        return entries
//    }
//}
//
//// MARK: - Archive Test Extension
//extension ArchiveManager {
//    
//    // MARK: - Data Creation Methods
//    
//    /// Создает тестовые данные для текущего месяца
//    func createTestData(count: Int = 10) {
//        print("🧪 ТЕСТ: Создание \(count) тестовых автомобилей за текущий месяц")
//        
//        let newEntries = TestDataGenerator.generateCarEntries(count: count, for: Date())
//        appFileManager.allItems.append(contentsOf: newEntries)
//        appFileManager.saveItemsToJSONFile()
//        
//        print("✅ ТЕСТ: Создано \(count) автомобилей")
//        printDataDistribution()
//        notifyDataUpdate()
//    }
//    
//    /// Создает данные за конкретный месяц в прошлом
//    func createTestDataForMonth(count: Int, monthsBack: Int) {
//        guard let targetDate = Calendar.current.date(byAdding: .month, value: -monthsBack, to: Date()) else {
//            print("❌ ТЕСТ: Ошибка вычисления даты для \(monthsBack) месяцев назад")
//            return
//        }
//        
//        print("🧪 ТЕСТ: Создание \(count) автомобилей за \(monthsBack) месяц(ев) назад")
//        
//        let newEntries = TestDataGenerator.generateCarEntries(count: count, for: targetDate)
//        appFileManager.allItems.append(contentsOf: newEntries)
//        appFileManager.saveItemsToJSONFile()
//        
//        print("✅ ТЕСТ: Добавлено \(count) автомобилей за целевой месяц")
//        notifyDataUpdate()
//    }
//    
//    // MARK: - Archive Control Methods
//    
//    /// Принудительная архивация для тестирования
//    func forceArchiveForTesting(year: Int? = nil, month: Int? = nil) {
//        let calendar = Calendar.current
//        let now = Date()
//        
//        let archiveYear = year ?? calendar.component(.year, from: now)
//        let archiveMonth = month ?? calendar.component(.month, from: now)
//        
//        print("🧪 ТЕСТ: Принудительная архивация за \(archiveMonth).\(archiveYear)")
//        print("🧪 ТЕСТ: Данных для архивации: \(appFileManager.allItems.count)")
//        
//        guard !appFileManager.allItems.isEmpty else {
//            print("⚠️ ТЕСТ: Нет данных для архивации! Добавьте автомобили сначала")
//            return
//        }
//        
//        ArchiveManager.shared.archiveCurrentDataToCSV(for: archiveYear, month: archiveMonth)
//    }
//    
//    /// Симулирует смену месяца для тестирования автоархивации
//    func simulateMonthChange(monthsBack: Int = 1) {
//        let calendar = Calendar.current
//        let now = Date()
//        
//        guard let pastDate = calendar.date(byAdding: .month, value: -monthsBack, to: now) else {
//            print("❌ ТЕСТ: Ошибка вычисления прошлой даты")
//            return
//        }
//        
//        print("🧪 ТЕСТ: Симуляция смены месяца на \(monthsBack) месяц(ев) назад")
//        saveLastKnownDate(pastDate)
//        print("✅ ТЕСТ: При следующем вызове checkArchiveOnAppStart() произойдет архивация")
//    }
//    
//    // MARK: - Debug Methods
//    
//    /// Подробная информация об архивах
//    func debugArchiveFiles() {
//        print("\n📊 === ОТЛАДКА АРХИВОВ ===")
//        
//        debugArchiveFolder()
//        debugArchiveMetadata()
//        debugCurrentData()
//        
//        print("📊 === КОНЕЦ ОТЛАДКИ ===\n")
//    }
//    
//    /// Показывает содержимое конкретного CSV файла
//    func debugCSVContent(fileName: String) {
//        let csvFileURL = csvArchivesFolderURL.appendingPathComponent(fileName)
//        
//        do {
//            let content = try String(contentsOf: csvFileURL, encoding: .utf8)
//            print("\n📄 СОДЕРЖИМОЕ: \(fileName)")
//            print(String(repeating: "=", count: 50))
//            print(content)
//            print(String(repeating: "=", count: 50))
//        } catch {
//            print("❌ Ошибка чтения файла \(fileName): \(error)")
//        }
//    }
//    
//    /// Полная очистка всех тестовых данных
//    func clearAllTestData() {
//        print("🧹 ОЧИСТКА: Удаление всех тестовых данных")
//        
//        let fileManager = FileManager.default
//        let filesToRemove = [
//            csvArchivesFolderURL,
//            archiveMetadataFileURL,
//            lastKnownDateFileURL
//        ]
//        
//        for fileURL in filesToRemove {
//            if fileManager.fileExists(atPath: fileURL.path) {
//                do {
//                    try fileManager.removeItem(at: fileURL)
//                    print("✅ Удален: \(fileURL.lastPathComponent)")
//                } catch {
//                    print("❌ Ошибка удаления \(fileURL.lastPathComponent): \(error)")
//                }
//            }
//        }
//        
//        // Очищаем текущие данные
//        appFileManager.allItems.removeAll()
//        appFileManager.saveItemsToJSONFile()
//        
//        print("✅ ОЧИСТКА: Все данные удалены")
//        notifyDataUpdate()
//    }
//    
//    // MARK: - Private Helper Methods
//    
//    private func saveLastKnownDate(_ date: Date) {
//        let calendar = Calendar.current
//        let dateComponents = DateComponents(
//            year: calendar.component(.year, from: date),
//            month: calendar.component(.month, from: date),
//            day: calendar.component(.day, from: date)
//        )
//        
//        do {
//            let data = try JSONEncoder().encode(dateComponents)
//            try data.write(to: lastKnownDateFileURL)
//        } catch {
//            print("❌ Ошибка сохранения тестовой даты: \(error)")
//        }
//    }
//    
//    private func printDataDistribution() {
//        let calendar = Calendar.current
//        var monthlyDistribution: [String: Int] = [:]
//        
//        for item in appFileManager.allItems {
//            let month = calendar.component(.month, from: item.date)
//            let year = calendar.component(.year, from: item.date)
//            let monthKey = "\(month).\(year)"
//            monthlyDistribution[monthKey, default: 0] += 1
//        }
//        
//        print("📊 Распределение по месяцам:")
//        for (key, count) in monthlyDistribution.sorted(by: { $0.key > $1.key }) {
//            print("   \(key): \(count) записей")
//        }
//    }
//    
//    private func debugArchiveFolder() {
//        let fileManager = FileManager.default
//        
//        print("📁 Папка архивов: \(csvArchivesFolderURL.path)")
//        print("📁 Существует: \(fileManager.fileExists(atPath: csvArchivesFolderURL.path))")
//        
//        do {
//            let files = try fileManager.contentsOfDirectory(
//                at: csvArchivesFolderURL,
//                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey]
//            )
//            
//            print("📄 Файлов: \(files.count)")
//            
//            for file in files {
//                let attributes = try fileManager.attributesOfItem(atPath: file.path)
//                let size = attributes[.size] as? Int ?? 0
//                let creationDate = attributes[.creationDate] as? Date ?? Date()
//                
//                print("  • \(file.lastPathComponent)")
//                print("    Размер: \(FileFormatter.formatFileSize(size))")
//                print("    Создан: \(FileFormatter.formatDate(creationDate))")
//                
//                showCSVPreview(at: file)
//            }
//        } catch {
//            print("❌ Ошибка чтения папки: \(error)")
//        }
//    }
//    
//    private func debugArchiveMetadata() {
//        let metadata = loadArchiveMetadata()
//        print("\n📋 Метаданные архивов: \(metadata.count)")
//        
//        for meta in metadata {
//            print("  • \(meta.monthDisplayName(Locale(identifier: "locale".localized))): \(meta.itemsCount) автомобилей")
//            print("    Файл: \(meta.fileName)")
//            print("    Создан: \(FileFormatter.formatDate(meta.createdAt))")
//        }
//    }
//    
//    private func debugCurrentData() {
//        print("\n📊 Текущие данные: \(appFileManager.allItems.count)")
//        
//        if !appFileManager.allItems.isEmpty {
//            let totalPrice = appFileManager.allItems.reduce(0) { $0 + $1.price }
//            let paidCount = appFileManager.allItems.filter { $0.isPaid }.count
//            print("    💰 Общая сумма: \(FileFormatter.formatPrice(totalPrice))")
//            print("    ✅ Оплачено: \(paidCount)/\(appFileManager.allItems.count)")
//        }
//    }
//    
//    private func showCSVPreview(at fileURL: URL) {
//        do {
//            let content = try String(contentsOf: fileURL, encoding: .utf8)
//            let lines = content.components(separatedBy: .newlines)
//            
//            print("    📄 Превью (первые 3 строки):")
//            for (index, line) in lines.prefix(3).enumerated() {
//                print("       \(index + 1): \(line)")
//            }
//            print("    📏 Всего строк: \(lines.count)")
//        } catch {
//            print("    ❌ Ошибка чтения: \(error)")
//        }
//    }
//    
//    private func notifyDataUpdate() {
//        NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
//    }
//}
//
//// MARK: - File Formatters
//struct FileFormatter {
//    
//    static func formatFileSize(_ bytes: Int) -> String {
//        let formatter = ByteCountFormatter()
//        formatter.allowedUnits = [.useKB, .useMB]
//        formatter.countStyle = .file
//        return formatter.string(fromByteCount: Int64(bytes))
//    }
//    
//    static func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd.MM.yyyy HH:mm"
//        return formatter.string(from: date)
//    }
//    
//    static func formatPrice(_ price: Double) -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencyCode = "USD"
//        formatter.maximumFractionDigits = 0
//        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
//    }
//}
//
//// MARK: - Automated Test Runner
//class AutomatedArchiveTest {
//    
//    private let archiveManager = ArchiveManager.shared
//    /// Полный автоматизированный тест всех функций архивации
//    static func runFullTestScenario() {
//        print("\n🤖 === ПОЛНЫЙ АВТОМАТИЗИРОВАННЫЙ ТЕСТ ===")
//        
//        // Этап 1: Подготовка
//        print("\n🧹 Этап 1: Очистка и подготовка")
//        ArchiveManager.shared.clearAllTestData()
//        
//        // Этап 2: Создание данных за разные периоды
//        print("\n📊 Этап 2: Создание тестовых данных")
//        ArchiveManager.shared.createTestDataForMonth(count: 5, monthsBack: 2)
//        ArchiveManager.shared.createTestDataForMonth(count: 8, monthsBack: 1)
//        ArchiveManager.shared.createTestData(count: 6)
//        
//        // Этап 3: Тестирование архивации
//        print("\n📦 Этап 3: Тестирование архивации")
//        
//        // Архивация за 2 месяца назад
//        ArchiveManager.shared.simulateMonthChange(monthsBack: 2)
//        ArchiveManager.shared.checkArchiveOnAppStart()
//        
//        // Архивация за прошлый месяц
//        ArchiveManager.shared.simulateMonthChange(monthsBack: 1)
//        ArchiveManager.shared.checkArchiveOnAppStart()
//        
//        // Возврат к текущей дате
//        ArchiveManager.shared.simulateMonthChange(monthsBack: 0)
//        
//        // Этап 4: Проверка результатов
//        print("\n🔍 Этап 4: Проверка результатов")
//        ArchiveManager.shared.debugArchiveFiles()
//        
//        validateTestResults()
//        
//        print("\n✅ === ПОЛНЫЙ ТЕСТ ЗАВЕРШЕН ===")
//    }
//    
//    /// Быстрый тест основных функций
//    static func runQuickTest() {
//        print("\n⚡ === БЫСТРЫЙ ТЕСТ ===")
//        
//        let archiveManager = ArchiveManager.shared
//        
//        archiveManager.createTestData(count: 3)
//        print("📊 Создано 3 тестовых автомобиля")
//        
//        ArchiveManager.shared.forceArchiveForTesting()
//        print("📦 Выполнена принудительная архивация")
//        
//        ArchiveManager.shared.debugArchiveFiles()
//        print("✅ Быстрый тест завершен")
//    }
//    
//    /// Тест загрузки данных из архивов
//    static func runLoadingTest() {
//        print("\n📥 === ТЕСТ ЗАГРУЗКИ АРХИВОВ ===")
//        
//        let archiveManager = ArchiveManager.shared
//        let availableMonths = archiveManager.getAvailableMonths()
//        
//        guard !availableMonths.isEmpty else {
//            print("⚠️ Нет архивов для тестирования загрузки")
//            return
//        }
//        
//        for month in availableMonths {
//            let items = archiveManager.getItemsForMonthPDF(year: month.year, month: month.month)
//            print("📅 \(month.displayName): загружено \(items.count) автомобилей")
//            
//            // Проверяем корректность загруженных данных
//            let totalPrice = items.reduce(0) { $0 + $1.price }
//            let paidCount = items.filter { $0.isPaid }.count
//            print("   💰 Общая сумма: \(FileFormatter.formatPrice(totalPrice))")
//            print("   ✅ Оплачено: \(paidCount)/\(items.count)")
//        }
//        
//        print("✅ Тест загрузки завершен")
//    }
//    
//    private static func validateTestResults() {
//        let archiveManager = ArchiveManager.shared
//        let availableMonths = archiveManager.getAvailableMonths()
//        
//        print("\n📋 Валидация результатов:")
//        print("📅 Доступно месяцев: \(availableMonths.count)")
//        
//        for month in availableMonths {
//            let items = archiveManager.getItemsForMonthPDF(year: month.year, month: month.month)
//            print("   • \(month.displayName): \(items.count) автомобилей")
//        }
//        
//        print("📊 Текущих данных в памяти: \(AppFileManager.shared.allItems.count)")
//        
//        // Проверяем, что архивы создались корректно
//        let archiveInfo = archiveManager.getArchiveInfo()
//        let expectedArchives = max(0, availableMonths.count - 1) // Текущий месяц не архивируется
//        
//        if archiveInfo.count >= expectedArchives {
//            print("✅ Архивы созданы корректно")
//        } else {
//            print("⚠️ Количество архивов меньше ожидаемого")
//        }
//    }
//}
//
//
//
//// MARK: - Test Button Configuration
//struct TestButtonConfig {
//    let title: String
//    let action: Selector
//    let style: ButtonStyle
//    
//    enum ButtonStyle {
//        case primary
//        case secondary
//        case danger
//        
//        var backgroundColor: UIColor {
//            switch self {
//            case .primary: return .systemBlue
//            case .secondary: return .systemGreen
//            case .danger: return .systemRed
//            }
//        }
//    }
//}
//
//// MARK: - Test Section Configuration
//struct TestSection {
//    let title: String
//    let buttons: [TestButtonConfig]
//}
//
//// MARK: - Archive Test View Controller
//class ArchiveTestViewController: UIViewController {
//    
//    // MARK: - UI Elements
//    private var scrollView: UIScrollView!
//    private var stackView: UIStackView!
//    
//    // MARK: - Test Sections Configuration
//    private lazy var testSections: [TestSection] = [
//        TestSection(
//            title: "📊 СОЗДАНИЕ ДАННЫХ",
//            buttons: [
//                TestButtonConfig(title: "Создать 5 авто (текущий месяц)", action: #selector(createSmallTestData), style: .primary),
//                TestButtonConfig(title: "Создать 15 авто (текущий месяц)", action: #selector(createLargeTestData), style: .primary),
//                TestButtonConfig(title: "Данные за прошлый месяц", action: #selector(createPastMonthData), style: .secondary),
//                TestButtonConfig(title: "Данные за 2 месяца назад", action: #selector(createTwoMonthsData), style: .secondary)
//            ]
//        ),
//        TestSection(
//            title: "🗓️ УПРАВЛЕНИЕ ВРЕМЕНЕМ",
//            buttons: [
//                TestButtonConfig(title: "Симулировать смену месяца (1)", action: #selector(simulateOneMonth), style: .primary),
//                TestButtonConfig(title: "Симулировать смену месяца (2)", action: #selector(simulateTwoMonths), style: .primary),
//                TestButtonConfig(title: "Сбросить на текущую дату", action: #selector(resetDate), style: .secondary)
//            ]
//        ),
//        TestSection(
//            title: "📦 АРХИВАЦИЯ",
//            buttons: [
//                TestButtonConfig(title: "Проверить автоархивацию", action: #selector(checkArchive), style: .primary),
//                TestButtonConfig(title: "Принудительная архивация", action: #selector(forceArchive), style: .primary),
//                TestButtonConfig(title: "Архив за прошлый месяц", action: #selector(archivePastMonth), style: .secondary)
//            ]
//        ),
//        TestSection(
//            title: "🔍 ОТЛАДКА",
//            buttons: [
//                TestButtonConfig(title: "Информация об архивах", action: #selector(debugArchives), style: .secondary),
//                TestButtonConfig(title: "Доступные месяцы", action: #selector(showAvailableMonths), style: .secondary),
//                TestButtonConfig(title: "Текущие данные", action: #selector(showCurrentData), style: .secondary),
//                TestButtonConfig(title: "Тест загрузки CSV", action: #selector(testCSVLoading), style: .secondary)
//            ]
//        ),
//        TestSection(
//            title: "🤖 АВТОТЕСТЫ",
//            buttons: [
//                TestButtonConfig(title: "Полный автотест", action: #selector(runFullAutomatedTest), style: .primary),
//                TestButtonConfig(title: "Быстрый автотест", action: #selector(runQuickAutomatedTest), style: .secondary),
//                TestButtonConfig(title: "Тест загрузки", action: #selector(runLoadingTest), style: .secondary)
//            ]
//        ),
//        TestSection(
//            title: "🧹 ОЧИСТКА",
//            buttons: [
//                TestButtonConfig(title: "Очистить текущие данные", action: #selector(clearCurrentData), style: .danger),
//                TestButtonConfig(title: "УДАЛИТЬ ВСЕ", action: #selector(clearAllData), style: .danger)
//            ]
//        )
//    ]
//    
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupViewController()
//        setupUI()
//    }
//    
//    // MARK: - Setup Methods
//    
//    private func setupViewController() {
//        title = "🚗 Тест CSV Архивации"
//        view.backgroundColor = .systemBackground
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Закрыть",
//            style: .done,
//            target: self,
//            action: #selector(closeTapped)
//        )
//    }
//    
//    private func setupUI() {
//        setupScrollView()
//        setupStackView()
//        createSections()
//        setupConstraints()
//    }
//    
//    private func setupScrollView() {
//        scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.showsVerticalScrollIndicator = true
//        view.addSubview(scrollView)
//    }
//    
//    private func setupStackView() {
//        stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.spacing = 16
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(stackView)
//    }
//    
//    private func createSections() {
//        // Заголовок
//        let titleLabel = createTitleLabel()
//        stackView.addArrangedSubview(titleLabel)
//        
//        // Разделитель
//        let separator = createSeparator()
//        stackView.addArrangedSubview(separator)
//        
//        // Секции с кнопками
//        for section in testSections {
//            createSection(section)
//        }
//    }
//    
//    private func createTitleLabel() -> UILabel {
//        let label = UILabel()
//        label.text = "Тестирование архивации автомобилей"
//        label.font = .boldSystemFont(ofSize: 20)
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        return label
//    }
//    
//    private func createSeparator() -> UIView {
//        let separator = UIView()
//        separator.backgroundColor = .systemGray4
//        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
//        return separator
//    }
//    
//    private func createSection(_ section: TestSection) {
//        // Заголовок секции
//        let sectionLabel = UILabel()
//        sectionLabel.text = section.title
//        sectionLabel.font = .boldSystemFont(ofSize: 16)
//        sectionLabel.textColor = .systemBlue
//        stackView.addArrangedSubview(sectionLabel)
//        
//        // Кнопки секции
//        for buttonConfig in section.buttons {
//            let button = createButton(from: buttonConfig)
//            stackView.addArrangedSubview(button)
//        }
//        
//        // Отступ после секции
//        let spacer = UIView()
//        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
//        stackView.addArrangedSubview(spacer)
//    }
//    
//    private func createButton(from config: TestButtonConfig) -> UIButton {
//        let button = UIButton(type: .system)
//        button.setTitle(config.title, for: .normal)
//        button.backgroundColor = config.style.backgroundColor
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 8
//        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
////        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
//        button.addTarget(self, action: config.action, for: .touchUpInside)
//        
//        // Анимация нажатия
//        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
//        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
//        
//        return button
//    }
//    
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
//            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
//            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
//            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
//            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
//        ])
//    }
//    
//    // MARK: - Button Actions - Data Creation
//    
//    @objc private func createSmallTestData() {
//        ArchiveManager.shared.createTestData(count: 5)
//        showSuccessAlert(message: "Создано 5 тестовых автомобилей")
//    }
//    
//    @objc private func createLargeTestData() {
//        ArchiveManager.shared.createTestData(count: 15)
//        showSuccessAlert(message: "Создано 15 тестовых автомобилей")
//    }
//    
//    @objc private func createPastMonthData() {
//        ArchiveManager.shared.createTestDataForMonth(count: 8, monthsBack: 1)
//        showSuccessAlert(message: "Создано 8 автомобилей за прошлый месяц")
//    }
//    
//    @objc private func createTwoMonthsData() {
//        ArchiveManager.shared.createTestDataForMonth(count: 6, monthsBack: 2)
//        showSuccessAlert(message: "Создано 6 автомобилей за 2 месяца назад")
//    }
//    
//    // MARK: - Button Actions - Time Management
//    
//    @objc private func simulateOneMonth() {
//        ArchiveManager.shared.simulateMonthChange(monthsBack: 1)
//        showSuccessAlert(message: "Дата изменена на 1 месяц назад")
//    }
//    
//    @objc private func simulateTwoMonths() {
//        ArchiveManager.shared.simulateMonthChange(monthsBack: 2)
//        showSuccessAlert(message: "Дата изменена на 2 месяца назад")
//    }
//    
//    @objc private func resetDate() {
//        ArchiveManager.shared.simulateMonthChange(monthsBack: 0)
//        showSuccessAlert(message: "Дата сброшена на текущую")
//    }
//    
//    // MARK: - Button Actions - Archive Operations
//    
//    @objc private func checkArchive() {
//        ArchiveManager.shared.checkArchiveOnAppStart()
//        showInfoAlert(title: "Проверка завершена", message: "Автоархивация проверена.\nДетали в консоли Xcode.")
//    }
//    
//    @objc private func forceArchive() {
//        ArchiveManager.shared.forceArchiveForTesting()
//        showSuccessAlert(message: "Принудительная архивация выполнена")
//    }
//    
//    @objc private func archivePastMonth() {
//        let calendar = Calendar.current
//        let now = Date()
//        guard let pastMonth = calendar.date(byAdding: .month, value: -1, to: now) else {
//            showErrorAlert(message: "Ошибка вычисления прошлого месяца")
//            return
//        }
//        
//        let month = calendar.component(.month, from: pastMonth)
//        let year = calendar.component(.year, from: pastMonth)
//        
//        ArchiveManager.shared.forceArchiveForTesting(year: year, month: month)
//        showSuccessAlert(message: "Архивация за прошлый месяц выполнена")
//    }
//    
//    // MARK: - Button Actions - Debug Operations
//    
//    @objc private func debugArchives() {
//        ArchiveManager.shared.debugArchiveFiles()
//        showInfoAlert(title: "Отладка завершена", message: "Информация об архивах выведена в консоль Xcode.")
//    }
//    
//    @objc private func showAvailableMonths() {
//        let months = ArchiveManager.shared.getAvailableMonths()
//        
//        if months.isEmpty {
//            showInfoAlert(title: "📅 Доступные месяцы", message: "Нет доступных месяцев с данными")
//            return
//        }
//        
//        var message = "Доступные месяцы с данными:\n\n"
//        for month in months {
//            let items = ArchiveManager.shared.getItemsForMonthPDF(year: month.year, month: month.month)
//            message += "• \(month.displayName): \(items.count) авто\n"
//        }
//        
//        showInfoAlert(title: "📅 Доступные месяцы", message: message)
//    }
//    
//    @objc private func showCurrentData() {
//        let items = AppFileManager.shared.allItems
//        
//        if items.isEmpty {
//            showInfoAlert(title: "📊 Текущие данные", message: "Нет данных в памяти")
//            return
//        }
//        
//        let totalPrice = items.reduce(0) { $0 + $1.price }
//        let paidCount = items.filter { $0.isPaid }.count
//        
//        let message = """
//        Записей в памяти: \(items.count)
//        Общая сумма: \(FileFormatter.formatPrice(totalPrice))
//        Оплачено: \(paidCount)/\(items.count)
//        Неоплачено: \(items.count - paidCount)
//        """
//        
//        showInfoAlert(title: "📊 Текущие данные", message: message)
//    }
//    
//    @objc private func testCSVLoading() {
//        let archives = ArchiveManager.shared.getArchiveInfo()
//        
//        if archives.isEmpty {
//            showInfoAlert(title: "⚠️ Тест загрузки", message: "Нет архивов для тестирования.\nСначала создайте архив.")
//            return
//        }
//        
//        // Тестируем загрузку всех архивов
//        print("🧪 ТЕСТ: Начинаем тест загрузки архивов")
//        
//        var successCount = 0
//        var totalItems = 0
//        
//        for _ in archives {
//            let availableMonths = ArchiveManager.shared.getAvailableMonths()
//            for month in availableMonths {
//                let items = ArchiveManager.shared.getItemsForMonthPDF(year: month.year, month: month.month)
//                if !items.isEmpty {
//                    successCount += 1
//                    totalItems += items.count
//                    print("✅ Загружен архив \(month.displayName): \(items.count) записей")
//                }
//            }
//        }
//        
//        let message = """
//        Тест загрузки завершен:
//        
//        Успешно загружено: \(successCount) архивов
//        Всего записей: \(totalItems)
//        
//        Подробности в консоли Xcode.
//        """
//        
//        showSuccessAlert(message: message)
//    }
//    
//    // MARK: - Button Actions - Automated Tests
//    
//    @objc private func runFullAutomatedTest() {
//        showLoadingAlert(title: "🤖 Автоматизированный тест", message: "Выполняется полный тест...\nМожет занять несколько секунд.")
//        
//        DispatchQueue.global(qos: .background).async {
//            AutomatedArchiveTest.runFullTestScenario()
//            
//            DispatchQueue.main.async {
//                self.dismissAlert()
//                self.showSuccessAlert(message: "Полный автоматизированный тест завершен.\n\nПроверьте консоль Xcode для подробных результатов.")
//            }
//        }
//    }
//    
//    @objc private func runQuickAutomatedTest() {
//        showLoadingAlert(title: "⚡ Быстрый тест", message: "Выполняется быстрый тест...")
//        
//        DispatchQueue.global(qos: .background).async {
//            AutomatedArchiveTest.runQuickTest()
//            
//            DispatchQueue.main.async {
//                self.dismissAlert()
//                self.showSuccessAlert(message: "Быстрый тест завершен.\n\nРезультаты в консоли Xcode.")
//            }
//        }
//    }
//    
//    @objc private func runLoadingTest() {
//        showLoadingAlert(title: "📥 Тест загрузки", message: "Тестируем загрузку архивов...")
//        
//        DispatchQueue.global(qos: .background).async {
//            AutomatedArchiveTest.runLoadingTest()
//            
//            DispatchQueue.main.async {
//                self.dismissAlert()
//                self.showSuccessAlert(message: "Тест загрузки завершен.\n\nРезультаты в консоли Xcode.")
//            }
//        }
//    }
//    
//    // MARK: - Button Actions - Cleanup
//    
//    @objc private func clearCurrentData() {
//        let alert = UIAlertController(
//            title: "⚠️ Подтверждение",
//            message: "Удалить только текущие данные в памяти?\n\n(Архивы останутся нетронутыми)",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
//            AppFileManager.shared.allItems.removeAll()
//            AppFileManager.shared.saveItemsToJSONFile()
//            NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
//            self.showSuccessAlert(message: "Текущие данные удалены")
//        })
//        
//        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
//        present(alert, animated: true)
//    }
//    
//    @objc private func clearAllData() {
//        let alert = UIAlertController(
//            title: "🚨 КРИТИЧЕСКОЕ ДЕЙСТВИЕ",
//            message: "Удалить ВСЕ данные включая все архивы?\n\n⚠️ Это действие НЕОБРАТИМО!\n⚠️ Все CSV архивы будут потеряны!",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "УДАЛИТЬ ВСЕ", style: .destructive) { _ in
//            ArchiveManager.shared.clearAllTestData()
//            self.showSuccessAlert(message: "Все данные и архивы полностью удалены")
//        })
//        
//        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
//        present(alert, animated: true)
//    }
//    
//    // MARK: - Navigation Actions
//    
//    @objc private func closeTapped() {
//        dismiss(animated: true)
//    }
//    
//    // MARK: - Button Animation
//    
//    @objc private func buttonTouchDown(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction) {
//            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//            sender.alpha = 0.8
//        }
//    }
//    
//    @objc private func buttonTouchUp(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction) {
//            sender.transform = .identity
//            sender.alpha = 1.0
//        }
//    }
//    
//    // MARK: - Alert Helpers
//    
//    private var currentAlert: UIAlertController?
//    
//    private func showSuccessAlert(message: String) {
//        showAlert(title: "✅ Успешно", message: message, style: .alert)
//    }
//    
//    private func showInfoAlert(title: String, message: String) {
//        showAlert(title: title, message: message, style: .alert)
//    }
//    
//    private func showErrorAlert(message: String) {
//        showAlert(title: "❌ Ошибка", message: message, style: .alert)
//    }
//    
//    private func showLoadingAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        // Добавляем индикатор загрузки
//        let loadingIndicator = UIActivityIndicatorView(style: .medium)
//        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
//        loadingIndicator.startAnimating()
//        
//        alert.setValue(loadingIndicator, forKey: "accessoryView")
//        
//        currentAlert = alert
//        present(alert, animated: true)
//    }
//    
//    private func dismissAlert() {
//        currentAlert?.dismiss(animated: true)
//        currentAlert = nil
//    }
//    
//    private func showAlert(title: String, message: String, style: UIAlertController.Style) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - Extensions for Easy Access
//extension UIViewController {
//    
//    /// Показывает контроллер тестирования архивации
//    func showArchiveTestController() {
//        let testController = ArchiveTestViewController()
//        let navController = UINavigationController(rootViewController: testController)
//        navController.modalPresentationStyle = .formSheet
//        
//        if let sheet = navController.sheetPresentationController {
//            sheet.detents = [.large()]
//            sheet.prefersGrabberVisible = true
//        }
//        
//        present(navController, animated: true)
//    }
//    
//    /// Запускает автоматизированный тест архивации
//    func runAutomatedArchiveTest() {
//        let alert = UIAlertController(
//            title: "🤖 Автоматизированное тестирование",
//            message: "Выберите тип теста для запуска:",
//            preferredStyle: .actionSheet
//        )
//        
//        alert.addAction(UIAlertAction(title: "Полный тест (рекомендуется)", style: .default) { _ in
//            self.executeAutomatedTest(type: .full)
//        })
//        
//        alert.addAction(UIAlertAction(title: "Быстрый тест", style: .default) { _ in
//            self.executeAutomatedTest(type: .quick)
//        })
//        
//        alert.addAction(UIAlertAction(title: "Тест загрузки", style: .default) { _ in
//            self.executeAutomatedTest(type: .loading)
//        })
//        
//        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
//        
//        // Для iPad
//        if let popover = alert.popoverPresentationController {
//            popover.sourceView = view
//            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
//            popover.permittedArrowDirections = []
//        }
//        
//        present(alert, animated: true)
//    }
//    
//    private enum TestType {
//        case full, quick, loading
//    }
//    
//    private func executeAutomatedTest(type: TestType) {
//        let loadingAlert = UIAlertController(
//            title: "🤖 Выполняется тест",
//            message: "Пожалуйста, подождите...",
//            preferredStyle: .alert
//        )
//        
//        let indicator = UIActivityIndicatorView(style: .medium)
//        indicator.translatesAutoresizingMaskIntoConstraints = false
//        indicator.startAnimating()
//        loadingAlert.setValue(indicator, forKey: "accessoryView")
//        
//        present(loadingAlert, animated: true)
//        
//        DispatchQueue.global(qos: .background).async {
//            switch type {
//            case .full:
//                AutomatedArchiveTest.runFullTestScenario()
//            case .quick:
//                AutomatedArchiveTest.runQuickTest()
//            case .loading:
//                AutomatedArchiveTest.runLoadingTest()
//            }
//            
//            DispatchQueue.main.async {
//                loadingAlert.dismiss(animated: true) {
//                    let successAlert = UIAlertController(
//                        title: "✅ Тест завершен",
//                        message: "Автоматизированный тест успешно выполнен.\n\nПодробные результаты смотрите в консоли Xcode.",
//                        preferredStyle: .alert
//                    )
//                    successAlert.addAction(UIAlertAction(title: "OK", style: .default))
//                    self.present(successAlert, animated: true)
//                }
//            }
//        }
//    }
//}
