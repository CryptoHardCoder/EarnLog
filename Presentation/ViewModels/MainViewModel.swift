//
//  MainViewModel.swift
//  JobData
//
//  Created by M3 pro on 30/07/2025.
//
//TODO: 1. Implement fetching notification data and update the bell icon color depending on whether there are notifications
///TODO: 2. Implement fetching the time of day and update the label
//•    morning — утро (примерно с 5–6 до 12)
//•    afternoon — после полудня, день (примерно 12–17)
//•    evening — вечер (примерно 17–21)
//•    night — ночь (после 21 и до рассвета)
//TODO: 3. Implement fetching the user's name and update the label
///TODO: 4. Implement fetching data for total, paid, and pending values
///TODO: 5.Create function for getting monthly goal and updating label
//TODO: 6.Create function for update descriptions in monthly goal card valгуs: moanthly goal and total values, after updating the card with the new values
//TODO: 7. Create function for updating statsCard with new values
import Foundation

final class MainViewModel: MemoryTrackable {
    @Published var lastEntriesPublisher = [IncomeEntry]()
    @Published var cardData = DataSummary()

    private let dataManager = AppCoreServices.shared.appFileManager
    private let statsManager = AppCoreServices.shared.statisticsCalculator
    private let dayPeriod = DayPeriod.fromNow()
    
    private var lastMonthEntries: [IncomeEntry] {
        statsManager.getLastMonthItems()
    }
    private var lastEntries:  [IncomeEntry]{
        let entries = dataManager.getAllItems()
        let lastEntries: [IncomeEntry]
        switch entries{
            case .success(let items):
                lastEntries = items.suffix(5)
            case .failure(_):
                lastEntries = []
        }
        return lastEntries
    }
    var lastTimeOfDay: String{
        dayPeriod.displayText
    } 
    
    var monthlyGoal: Int{
        get{
            let goal = UserDefaults.standard.string(forKey: "monthlyGoal") ?? ""
            return Int(goal) ?? 0
        }
        set {
            
        }
    } 
    
    var onDataChanged: (() -> Void)?
    
    init() {
        refreshData()
    }
    
    private func refreshData(){
        lastEntriesPublisher = lastEntries
    }

    func getTimesOfDay(){
       
    } 
    
    func getUserName(){
        
    }
    
    func getNotificationsState(){
        
    }
    
    func getIncomeDataForCard(){
        cardData = statsManager.getLastMonthStats()
    }

    //FIXME: - Переписать на норм
    func getMonthlyGoalStats() -> (goal: Int, total: Int){
        if monthlyGoal == 0 {
            print("Mock goal value installed")
            UserDefaults.standard.set(8000, forKey: "monthlyGoal")
            monthlyGoal = 8000
        }
        let total = lastMonthEntries.reduce(0) { $0 + $1.price}
        return (goal: monthlyGoal, total: Int(total))
    }
    
    func getLastMonthStats() -> [(String, Int)]{
        let items = statsManager.getLastMonthItems()
        let statsData = Array(statsManager.getTotalWithSources(in: items).prefix(4))
        return statsData
    }
    func getLastItems(){
        
    }
}
//class MainViewModel: MemoryTrackable {
//    // MARK: - Properties (данные для View)
//    var lastEntries = [IncomeEntry]()
////    var filteredEntries: [IncomeEntry] = []
//    
//    var sources: [IncomeSource]{
//        AppFileManager.shared.sources
//    }
//    
//    var currentFilter: TimeFilter = .month
//    var dailyGoal: String = ""
//    var isGoalEnabled: Bool = true
//    var todayDate: String = ""
//    
//    // MARK: - Callbacks (чтобы View знал об изменениях)
//    var onDataChanged: (() -> Void)?
//    var onGoalChanged: (() -> Void)?
//    var onFilterChanged: (() -> Void)?
//    var onDateChanged: (() -> Void)?
//    
//    // MARK: - Private Properties
//    private let dateFormatter = DateFormatter()
//    
//    init(){
//        trackCreation()
//        setupDateFormatter()
//        loadInitialData()
//    }
//    
//    // MARK: - Setup Methods
//    private func setupDateFormatter() {
//        dateFormatter.dateFormat = "dd.MM.yyyy"
//        todayDate = dateFormatter.string(from: Date())
//    }
//    
//    
//    func updateCurrentDate() {
//        let newDate = dateFormatter.string(from: Date())
//        if todayDate != newDate {
//            todayDate = newDate
//            onDateChanged?()
//        }
//    }
//   
//    
//    // MARK: - Data Loading
//    private func loadInitialData() {
//         //Загружаем данные при старте
////        print("loadInitialData allitems: \(AppFileManager.shared.allItems)")
//        if AppFileManager.shared.allItems.isEmpty {
//            AppFileManager.shared.loadOrCreateInBackground { [weak self] in
//                DispatchQueue.main.async {
//                    self?.refreshData()
//                }
//            }
//        } else {
//            refreshData()
//        }
//        
//        // Загружаем сохраненную цель
//        loadGoalData()
//    }
//    
//    func refreshData() {
//        lastEntries = AppFileManager.shared.getFilteredItems(for: currentFilter)
//        onDataChanged?() // 📢 Говорим View что данные обновились
//    }
//    
//    private func loadGoalData() {
//        dailyGoal = UserDefaults.standard.string(forKey: "dailyGoal") ?? ""
//        let wasGoalSet = UserDefaults.standard.bool(forKey: "wasGoalSet")
//        isGoalEnabled = !wasGoalSet
//        onGoalChanged?() // 📢 Говорим View что цель обновилась
//    }
//    
//    // MARK: - Car Entry Methods
//    func saveNewEntry(car: String, price: Double, source: IncomeSource) -> Bool {
//        guard !car.isEmpty, price > 0 else {
//            return false // Возвращаем false если данные неверные
//        }
//        
//        let newEntry = IncomeEntry(date: Date(), car: car, price: price, isPaid: false, source: source)
//        AppFileManager.shared.addNewItem(newEntry)
//        refreshData()
//        return true
//    }
//    
////    func togglePaymentStatus(for entryId: UUID) {
////        AppFileManager.shared.togglePaymentStatus(for: entryId)
////        refreshData()
////        NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
////    }
//    
//    // MARK: - Goal Methods
//    func saveGoal(_ goal: String) {
//        guard !goal.isEmpty else { return }
//        
//        UserDefaults.standard.set(goal, forKey: "dailyGoal")
//        UserDefaults.standard.set(true, forKey: "wasGoalSet")
//        UserDefaults.standard.set(false, forKey: "wasEditing")
//        
//        let target = Double(goal) ?? 0
//        UserDefaults.standard.set(target, forKey: "targetValue")
//        
//        // Обновляем состояние
//        dailyGoal = goal
//        isGoalEnabled = false
//        
//        onGoalChanged?() // 📢 Говорим View что цель изменилась
////        NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
//    }
//    
//    func enableGoalEditing() {
//        isGoalEnabled = true
//        UserDefaults.standard.set(true, forKey: "wasEditing")
//        onGoalChanged?() // 📢 Говорим View что нужно включить редактирование
//    }
//    
//    // MARK: - Filter Methods
//    func changeFilter(to filter: TimeFilter) {
//        currentFilter = filter
//        refreshData()
//        onFilterChanged?() // 📢 Говорим View что фильтр изменился
//    }
//    
//    func changeFilterByIndex(_ index: Int) {
//        let filters = TimeFilter.allCases
//        guard index < filters.count else { return }
//        changeFilter(to: filters[index])
//    }
//    
//    // MARK: - Validation
//    func validateCarEntryInput(car: String?, price: String?, source: IncomeSource) -> (Bool, String) {
//        guard let car = car, !car.isEmpty else { return (false, "error_empty_car".localized) }
//        guard let priceText = price, !priceText.isEmpty, Double(priceText) != nil else {
//            return (false, "error_price_empty".localized)}
//    
//        return (true, "")
//    }
//    
//    deinit {
//        trackDeallocation() // для анализа на memory leaks
//    }
//}
