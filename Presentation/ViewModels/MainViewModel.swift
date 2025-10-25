//
//  MainViewModel.swift
//  JobData
//
//  Created by M3 pro on 30/07/2025.

import Foundation
import Combine

struct MainViewData {
    let lastEntries: [IncomeEntry]
    let cardData: DataSummary
    let monthlyGoalStats: (goal: Double, total: Double)
    let lastMonthStats: [(String, Double)]
}

final class MainViewModel: MainViewModelProtocol, MemoryTrackable {
    @Published var viewState: ViewState<MainViewData> = .ready
    var lastTimeOfDay: String {
        dayPeriod.displayText
    }
    private let getCurrentMonthItemsUseCase: GetCurrentMonthItemsUseCase
    private var userMonthlyGoalUseCase: UserMonthlyGoalUseCase  // вместо прямого UserDefaults
        
    private var dayPeriod: DayPeriod{
        DayPeriod.fromNow()
    }
    private var cancellables = Set<AnyCancellable>()
        
    init(
        getCurrentMonthItemsUseCase: GetCurrentMonthItemsUseCase,
        userMonthlyGoalUseCase: UserMonthlyGoalUseCase
    ) {
        self.getCurrentMonthItemsUseCase = getCurrentMonthItemsUseCase
        self.userMonthlyGoalUseCase = userMonthlyGoalUseCase
        subscribeToDataUpdates()
    }
    
    func loadData() async {
        viewState = .loading
        
        do {
            let entries = try await getCurrentMonthItemsUseCase.execute().sorted { $0.date > $1.date }
            let data = MainViewData(
                lastEntries: Array(entries.prefix(5)),
                cardData: StatisticsCalculator.getCurrentMonthStats(from: entries),
                monthlyGoalStats: calculateMonthlyGoalStats(from: entries),
                lastMonthStats: Array(StatisticsCalculator.getTotalWithSources(in: entries).prefix(4))
            )
            viewState = .loaded(data)
            
        } catch {
            viewState = .error("Ошибка при загрузке данных: \(error.localizedDescription)")
        }
    }
    
    private func subscribeToDataUpdates() {
        DataUpdateCoordinator.shared.events
            .sink { [weak self] event in
                switch event {
                    case .newIncomeEntryCreated:
                       Task {
                            await self?.loadData()
                        }
                    case .incomeEntryUpdated(_):
                        break
                    case .incomeEntryDeleted(_):
                        Task {
                             await self?.loadData()
                         }
                    case .goalUpdated:
                        Task {
                             await self?.loadData()
                         }
                    case .statisticsNeedRefresh:
                        break
                }
            }
            .store(in: &cancellables)
    }
        
    private func calculateMonthlyGoalStats(from entries: [IncomeEntry]) -> (goal: Double, total: Double) {
        var goal = userMonthlyGoalUseCase.monthlyGoal
        if goal == 0.0 {
            print("Mock goal value installed")
            UserDefaults.standard.set(10000.00, forKey: "monthlyGoal")
            goal = 10000.00
        }
        let total = entries.reduce(0.0) { $0 + $1.price }
        return (goal: goal, total: total)
    }

    func getUserName(){
        
    }
    
    func getNotificationsState(){
        
    }
    
    
//    private var currentMonthEntries: [IncomeEntry] {
//        get async {
//            do{
//                return try await getCurrentMonthItemsUseCase.execute()
//            } catch {
//                return []
//            }
//        }
//    }
//    private var lastEntries: [IncomeEntry]{
//        get async {
//            await currentMonthEntries.suffix(5)
//        }
//    } 
//    var lastTimeOfDay: String{
//        dayPeriod.displayText
//    } 
//    
//    var monthlyGoal: Int{
//        get{
//            let goal = UserDefaults.standard.string(forKey: "monthlyGoal") ?? ""
//            return Int(goal) ?? 0
//        }
//        set {
//            
//        }
//    } 
//    
//    init( getCurrentMonthItemsUseCase: GetCurrentMonthItemsUseCase) {
//        self.getCurrentMonthItemsUseCase = getCurrentMonthItemsUseCase
//    }
//    
//    private func refreshData(){
//        Task{
//            do{
//                lastEntriesPublisher = await lastEntries
//            }
//        }
//    }

   
//    func getIncomeDataForCard(){
//        var items: [IncomeEntry] 
//        Task {
//            items = await currentMonthEntries
//        }
//        cardData = StatisticsCalculator.getCurrentMonthStats(from: items)
//    }

    //FIXME: - Переписать на норм
//    func getMonthlyGoalStats() -> (goal: Int, total: Int){
//        if monthlyGoal == 0 {
//            print("Mock goal value installed")
//            UserDefaults.standard.set(8000, forKey: "monthlyGoal")
//            monthlyGoal = 8000
//        }
//        var total: Double
//        Task{
//           total = await currentMonthEntries.reduce(0) { $0 + $1.price}
//        }
//        return (goal: monthlyGoal, total: Int(total))
//    }
    
//    func getLastMonthStats() -> [(String, Int)]{
//        var items: [IncomeEntry] 
//        Task {
//            items = await currentMonthEntries
//        }
//        let statsData = Array(StatisticsCalculator.getTotalWithSources(in: items).prefix(4))
//        return statsData
//    }
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
