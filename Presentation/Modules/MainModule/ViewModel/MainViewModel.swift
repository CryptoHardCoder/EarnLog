//
//  MainViewModel.swift
//  JobData
//
//  Created by M3 pro on 30/07/2025.
//
import Foundation
import Combine

    // MARK: - View Models (Презентационные модели для View)
struct GreetingViewData {
    let timeOfDay: String
    let userName: String
    let avatarImageName: String
}

struct CardViewData {
    let totalAmount: String
    let paidAmount: String
    let pendingAmount: String
    let totalRaw: Double
    let paidRaw: Double
    let pendingRaw: Double
}

enum GoalViewType {
    case empty
    case withStats(GoalStatsViewData)
}

struct GoalStatsViewData {
    let currentAmount: String
    let goalAmount: String
    let progressPercentage: Double
    let topSources: [SourceStatViewData]
    let currentRaw: Double
    let goalRaw: Double
}

struct SourceStatViewData {
    let name: String
    let amount: String
    let amountRaw: Double
}

enum EntriesViewType {
    case empty(EmptyStateViewData)
    case entries([EntryViewData])
}

struct EmptyStateViewData {
    let title: String
    let description: String
    let iconName: String?
}

struct EntryViewData: IncomesCellDisplayable{
    var displayDate: Date
    var displayTitle: String
    var displayAmount: Double
    var displayStatus: Bool
    var displaySource: String
}

    // MARK: - ViewModel Implementation

final class MainViewModel: MainViewModelProtocol {

    var viewStatePublisher: AnyPublisher<ViewState<MainViewData>, Never> {
        $viewState.eraseToAnyPublisher()
    }

    @Published private var viewState: ViewState<MainViewData> = .ready

    private let getCurrentMonthItemsUseCase: GetCurrentMonthItemsUseCase
    private var userMonthlyGoalUseCase: GetUserMonthlyGoalUseCase
    private var userGoal: Double = 0.0
    private var currentEntries: [IncomeEntry] = []

    private var dayPeriod: DayPeriod {
        DayPeriod.fromNow()
    }

    private var cancellables = Set<AnyCancellable>()

    private enum Constants {
        static let maxRecentEntries = 5
        static let maxTopSources = 4
        static let defaultUserName = "Anna Smith" // FIXME: Получать из UserDefaults или UseCase
        static let defaultAvatarName = "avatar" // FIXME: Получать из UserDefaults или UseCase
    }

    init(
        getCurrentMonthItemsUseCase: GetCurrentMonthItemsUseCase,
        userMonthlyGoalUseCase: GetUserMonthlyGoalUseCase
    ) {
        self.getCurrentMonthItemsUseCase = getCurrentMonthItemsUseCase
        self.userMonthlyGoalUseCase = userMonthlyGoalUseCase
        subscribeToDataUpdates()
    }

    func loadData() async {
        viewState = .loading
        userGoal = await userMonthlyGoalUseCase.execute() ?? 0.0

        do {
            let entries = try await getCurrentMonthItemsUseCase.execute()
                .sorted { $0.date > $1.date }
            currentEntries = entries
            let data = makeViewData(from: entries)
            viewState = .loaded(data)
        } catch {
            viewState = .error("Ошибка при загрузке данных: \(error.localizedDescription)")
        }
    }

        // MARK: - Private Methods

    private func makeViewData(from entries: [IncomeEntry]) -> MainViewData {
        let greeting = makeGreetingViewData()
        let card = makeCardViewData(from: entries)
        let goalView = makeGoalViewType(from: entries)
        let entriesView = makeEntriesViewType(from: entries)
        let shouldShowRecentActivitySection = !entries.isEmpty

        return MainViewData(
            greeting: greeting,
            card: card,
            goalView: goalView,
            entriesView: entriesView,
            shouldShowRecentActivitySection: shouldShowRecentActivitySection
        )
    }

    private func makeGreetingViewData() -> GreetingViewData {
        return GreetingViewData(
            timeOfDay: dayPeriod.displayText,
            userName: Constants.defaultUserName,
            avatarImageName: Constants.defaultAvatarName
        )
    }

    private func makeCardViewData(from entries: [IncomeEntry]) -> CardViewData {
        let stats = StatisticsCalculator.getCurrentMonthStats(from: entries)

        return CardViewData(
            totalAmount: formatCurrency(stats.totalVolume),
            paidAmount: formatCurrency(stats.paidVolume),
            pendingAmount: formatCurrency(stats.unpaidVolume),
            totalRaw: stats.totalVolume,
            paidRaw: stats.paidVolume,
            pendingRaw: stats.unpaidVolume
        )
    }

    private func makeGoalViewType(from entries: [IncomeEntry]) -> GoalViewType {
        guard userGoal > 0.0 else { return .empty }

        let total = entries.reduce(0.0) { $0 + $1.price }
        let progressPercentage = min((total / userGoal) * 100, 100)

        let topSources = StatisticsCalculator.getTotalWithSources(in: entries)
            .prefix(Constants.maxTopSources)
            .map { SourceStatViewData(
                name: $0.0,
                amount: formatCurrency($0.1),
                amountRaw: $0.1
            )}

        let goalStats = GoalStatsViewData(
            currentAmount: formatCurrency(total),
            goalAmount: formatCurrency(userGoal),
            progressPercentage: progressPercentage,
            topSources: Array(topSources),
            currentRaw: total,
            goalRaw: userGoal
        )

        return .withStats(goalStats)
    }

    private func makeEntriesViewType(from entries: [IncomeEntry]) -> EntriesViewType {
        guard !entries.isEmpty else {
            let emptyState = EmptyStateViewData(
                title: "No Income Resources Added Yet",
                description: "Click \"Add New Income\" Button To Start Tracking",
                iconName: "tray.fill"
            )
            return .empty(emptyState)
        }

        let entryViewModels = entries
            .prefix(Constants.maxRecentEntries)
            .map { entry -> EntryViewData in
                EntryViewData(
                    displayDate: entry.date,
                    displayTitle: entry.jobTitle,
                    displayAmount: entry.price,
                    displayStatus:entry.isPaid,
                    displaySource: entry.source.displayName
                )
            }

        return .entries(Array(entryViewModels))
    }

    private func subscribeToDataUpdates() {
        DataUpdateCoordinator.shared.events
            .sink { [weak self] event in
                switch event {
                    case .newIncomeEntryCreated, .incomeEntryDeleted, .goalUpdated:
                        Task {
                            await self?.loadData()
                        }
                    case .incomeEntryUpdated, .statisticsNeedRefresh:
                        break
                }
            }
            .store(in: &cancellables)
    }

        // MARK: - Formatters

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$" // FIXME: Получать из настроек пользователя
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
}

    // MARK: - Usage Example in ViewController

/*

 // В MainViewController теперь только рисование:

 private func updateUI(with data: MainViewData) {
 updateGreeting(data.greeting)
 updateCard(data.card)
 updateGoalView(data.goalView)
 updateEntriesView(data.entriesView)
 updateRecentActivitySection(visible: data.shouldShowRecentActivitySection)
 }

 private func updateGreeting(_ greeting: GreetingViewModel) {
 greetingTitle.text = greeting.timeOfDay
 nameTitle.text = greeting.userName
 avatarImage.image = UIImage(named: greeting.avatarImageName)
 }

 private func updateCard(_ card: CardViewModel) {
 cardView.updateData(
 total: card.totalRaw,
 paid: card.paidRaw,
 pending: card.pendingRaw
 )
 // Или если CardView работает со строками:
 // cardView.updateData(
 //     total: card.totalAmount,
 //     paid: card.paidAmount,
 //     pending: card.pendingAmount
 // )
 }

 private func updateGoalView(_ goalViewType: GoalViewType) {
 switch goalViewType {
 case .empty:
 if currentGoalViewState != .empty {
 setupEmptyGoalView()
 currentGoalViewState = .empty
 }
 case .withStats(let stats):
 if currentGoalViewState != .withData {
 setupGoalAndStatsCardView()
 currentGoalViewState = .withData
 }
 updateGoalStatsView(with: stats)
 }
 }

 private func updateGoalStatsView(with stats: GoalStatsViewModel) {
 guard let goalView = currentGoalView as? GoalAndStatsCardView else { return }
 goalView.setGoalValues(
 current: stats.currentRaw,
 goal: stats.goalRaw
 )
 goalView.setStatsValues(newValues: stats.topSources.map { ($0.name, $0.amountRaw) })
 }

 private func updateEntriesView(_ entriesViewType: EntriesViewType) {
 switch entriesViewType {
 case .empty(let emptyState):
 if currentEntriesViewState != .empty {
 clearEntriesContainer()
 setupEmptyDataView(with: emptyState)
 currentEntriesViewState = .empty
 }
 case .entries:
 if currentEntriesViewState != .withData {
 clearEntriesContainer()
 setupCollectionView()
 currentEntriesViewState = .withData
 } else {
 lastEntriesCollectionView?.reloadData()
 updateCollectionHeight()
 }
 }
 }

 // UICollectionViewDataSource
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
 guard let data = currentData,
 case .entries(let entries) = data.entriesView else {
 return 0
 }
 return entries.count
 }

 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 let cell = collectionView.dequeueReusableCell(...) as! IncomeCollectionViewCell

 guard let data = currentData,
 case .entries(let entries) = data.entriesView,
 indexPath.item < entries.count else {
 return cell
 }

 let entry = entries[indexPath.item]
 cell.configure(with: entry) // Теперь configure принимает EntryViewModel
 return cell
 }

 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
 viewModel.didSelectEntry(at: indexPath.item)
 }

 */
//import Foundation
//import Combine
//
//final class MainViewModel: MainViewModelProtocol{
//
//    var viewStatePublisher: AnyPublisher<ViewState<MainViewData>, Never> { $viewState.eraseToAnyPublisher() }
//
//    @Published private var viewState: ViewState<MainViewData> = .ready
//
//    private let getCurrentMonthItemsUseCase: GetCurrentMonthItemsUseCase
//    private var userMonthlyGoalUseCase: GetUserMonthlyGoalUseCase
//    private var userGoal: Double = 0.0
//
//    private var dayPeriod: DayPeriod{
//        DayPeriod.fromNow()
//    }
//    private var cancellables = Set<AnyCancellable>()
//
//    private enum Constants {
//        static let maxRecentEntries = 5
//        static let maxTopSources = 4
//    }
//
//    init(
//        getCurrentMonthItemsUseCase: GetCurrentMonthItemsUseCase,
//        userMonthlyGoalUseCase: GetUserMonthlyGoalUseCase
//    ) {
//        self.getCurrentMonthItemsUseCase = getCurrentMonthItemsUseCase
//        self.userMonthlyGoalUseCase = userMonthlyGoalUseCase
//        subscribeToDataUpdates()
//    }
//    
//    func loadData() async {
//        viewState = .loading
//        userGoal = await userMonthlyGoalUseCase.execute() ?? 0.0
//
//        do {
//            let entries = try await getCurrentMonthItemsUseCase.execute().sorted { $0.date > $1.date }
//            let data = makeViewData(from: entries)
//            viewState = .loaded(data)
//        } catch {
//            viewState = .error("Ошибка при загрузке данных: \(error.localizedDescription)")
//        }
//    }
//
//    private func makeViewData(from entries: [IncomeEntry]) -> MainViewData {
//        let total = entries.reduce(0.0) { $0 + $1.price }
//
//        return MainViewData(
//            lastTimeOfDay: dayPeriod.displayText,
//            lastEntries: Array(entries.prefix(Constants.maxRecentEntries)),
//            cardData: StatisticsCalculator.getCurrentMonthStats(from: entries),
//            monthlyGoalStats: (goal: userGoal, total: total),
//            lastMonthStats: Array(StatisticsCalculator.getTotalWithSources(in: entries).prefix(Constants.maxTopSources)),
//            setEmptyGoal: userGoal <= 0.0,
//            setEmptyEntries: entries.isEmpty
//        )
//    }
//
//    private func subscribeToDataUpdates() {
//        DataUpdateCoordinator.shared.events
//            .sink { [weak self] event in
//                switch event {
//                    case .newIncomeEntryCreated:
//                       Task {
//                            await self?.loadData()
//                        }
//                    case .incomeEntryUpdated(_):
//                        break
//                    case .incomeEntryDeleted(_):
//                        Task {
//                             await self?.loadData()
//                         }
//                    case .goalUpdated:
//                        Task {
//                             await self?.loadData()
//                         }
//                    case .statisticsNeedRefresh:
//                        break
//                }
//            }
//            .store(in: &cancellables)
//    }
////        
////    private func calculateTotal(from entries: [IncomeEntry]) -> Double {
////
////
////
//////        if goal == 0.0 {
//////            UserDefaults.standard.set(10000.0, forKey: "monthlyGoal")
//////            goal = 10000.0
//////        }
////
////        entries.reduce(0.0) { $0 + $1.price }
////
////    }
//
//    func getUserName(){
//        
//    }
//    
//    func getNotificationsState(){
//        
//    }
//    
//    
////    private var currentMonthEntries: [IncomeEntry] {
////        get async {
////            do{
////                return try await getCurrentMonthItemsUseCase.execute()
////            } catch {
////                return []
////            }
////        }
////    }
////    private var lastEntries: [IncomeEntry]{
////        get async {
////            await currentMonthEntries.suffix(5)
////        }
////    } 
////    var lastTimeOfDay: String{
////        dayPeriod.displayText
////    } 
////    
////    var monthlyGoal: Int{
////        get{
////            let goal = UserDefaults.standard.string(forKey: "monthlyGoal") ?? ""
////            return Int(goal) ?? 0
////        }
////        set {
////            
////        }
////    } 
////    
////    init( getCurrentMonthItemsUseCase: GetCurrentMonthItemsUseCase) {
////        self.getCurrentMonthItemsUseCase = getCurrentMonthItemsUseCase
////    }
////    
////    private func refreshData(){
////        Task{
////            do{
////                lastEntriesPublisher = await lastEntries
////            }
////        }
////    }
//
//   
////    func getIncomeDataForCard(){
////        var items: [IncomeEntry] 
////        Task {
////            items = await currentMonthEntries
////        }
////        cardData = StatisticsCalculator.getCurrentMonthStats(from: items)
////    }
//
//    //FIXME: - Переписать на норм
////    func getMonthlyGoalStats() -> (goal: Int, total: Int){
////        if monthlyGoal == 0 {
////            print("Mock goal value installed")
////            UserDefaults.standard.set(8000, forKey: "monthlyGoal")
////            monthlyGoal = 8000
////        }
////        var total: Double
////        Task{
////           total = await currentMonthEntries.reduce(0) { $0 + $1.price}
////        }
////        return (goal: monthlyGoal, total: Int(total))
////    }
//    
////    func getLastMonthStats() -> [(String, Int)]{
////        var items: [IncomeEntry] 
////        Task {
////            items = await currentMonthEntries
////        }
////        let statsData = Array(StatisticsCalculator.getTotalWithSources(in: items).prefix(4))
////        return statsData
////    }
//    func getLastItems(){
//        
//    }
//}
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
