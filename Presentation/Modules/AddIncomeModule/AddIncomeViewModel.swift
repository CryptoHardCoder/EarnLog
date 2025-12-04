//
//  AddIncomeViewModel.swift
//  EarnLog
//
//  Created by M3 pro on 16/10/2025.
//

import Foundation
import Combine

// MARK: - Advanced ViewModel with State Machine
final class AddIncomeViewModel: AddIncomeViewModelProtocol, ObservableObject {



    // MARK: - Published Properties
//    var viewStatePublisher: Published<ViewState<[String]>>.Publisher { $viewState }

    @Published private var viewState: ViewState<[String]> = .ready

    var viewStatePublisher: AnyPublisher<ViewState<[String]>, Never> {
        $viewState.eraseToAnyPublisher()
    }


    var isPaid: Bool?
    
    var mainJobName: String {
        mainJob.displayName
    }
    
    // MARK: - Private Properties
    private var sideJobsForDisplay: [String] = []
    private var sideJobs: [IncomeSource] = []
    private let mainJob: IncomeSource = .mainJob
    private(set) var selectedSource: IncomeSource?
    
    private let getAllActiveSideJobsUseCase: GetActiveSideJobsUseCase
    private let saveItemUseCase: SaveItemUseCase
    
    // MARK: - Initialization
    init(
        getAllActiveSideJobsUseCase: GetActiveSideJobsUseCase,
        saveItemUseCase: SaveItemUseCase
    ) {
        self.getAllActiveSideJobsUseCase = getAllActiveSideJobsUseCase
        self.saveItemUseCase = saveItemUseCase
    }
    
    // MARK: - Public Methods
    func loadData() async {
        await updateState(.loading)
        
        do {
            let fetchedSideJobs = try await getAllActiveSideJobsUseCase.execute()
            let sources = fetchedSideJobs.map { IncomeSource.sideJob($0) }
            
            await MainActor.run {
                self.sideJobs = sources
                self.sideJobsForDisplay = sources.map { $0.displayName }
                self.viewState = .loaded(sideJobsForDisplay)
            }
        } catch {
            await updateState(.error("Failed to load part-time jobs"))
        }
    }
    
    func saveNewItem(
        title: String,
        description: String?,
        price: Double,
        date: Date
    ) async {
       let validationResult = validateInput(title: title, price: price)
        switch validationResult{
            case .success(()):
                // Сохранение
                await updateState(.loading)
                
                let entry = IncomeEntry(
                    date: date,
                    jobTitle: title,
                    jobDescription: description,
                    price: price,
                    isPaid: isPaid!,
                    source: selectedSource!
                )
                
                do {
                    try await saveItemUseCase.execute(new: entry)
                    await updateState(.success("Income entry saved successfully"))
                    DataUpdateCoordinator.shared.notifyNewIncomeEntryCreated()
                    resetForm()
                } catch {
                    await updateState(.error("Failed to save new income"))
                }

            case .failure(let error):
                await updateState(.error(error.errorDescription))
        }
        
    }
    
    func selectSource(sourceName: String) {
        if sourceName == mainJob.displayName {
            selectedSource = mainJob
        } else {
            selectedSource = sideJobs.first { $0.displayName == sourceName }
        }
    }

    private func validateInput(title: String, price: Double) -> Result< Void, ValidationError >{
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.emptyTitle)
        }
        
        guard price > 0 else {
            return .failure(.invalidPrice)
        }
        
        
        guard isPaid != nil else {
            return .failure(.missingState)
        }
        
        guard selectedSource != nil else {
            return .failure(.missingSource)
        }
        
        return .success(())
    }
    
    // MARK: - Private Methods
    private func resetForm() {
        isPaid = nil
        selectedSource = nil
    }
    
    @MainActor
    private func updateState(_ state: ViewState<[String]>) {
        self.viewState = state
    }
}

// MARK: - Validation Errors
enum ValidationError: LocalizedError {
    case emptyTitle
    case invalidPrice
    case missingState
    case missingSource
    case missingDate
    
    var errorDescription: String {
        switch self {
        case .emptyTitle:
            return "Income title cannot be empty"
        case .invalidPrice:
            return "Price must be greater than zero"
        case .missingState:
            return "Please select income state (Earned/Expected)"
        case .missingSource:
            return "Please select income source"
        case .missingDate:
            return  "Please select date"
        }
    }
}




//import Foundation
//
//// MARK: - AddIncomeViewModel
//final class AddIncomeViewModel: ObservableObject {
//    
//    // MARK: - Published Properties
//    @Published private(set) var sideJobsForDisplay: [String] = []
//    @Published private(set) var errorMessage: String = ""
//    @Published private(set) var acceptMessage: String = ""
//    @Published private(set) var isLoading: Bool = false
//    
//    // MARK: - Input Properties
//    var isPaid: Bool?
//    
//    // MARK: - Computed Properties
//    var mainJobName: String {
//        mainJob.displayName
//    }
//    
//    // MARK: - Private Properties
//    private var sideJobs: [IncomeSource] = [] {
//        didSet {
//            updateSideJobsForDisplay()
//        }
//    }
//    
//    private let mainJob: IncomeSource = .mainJob
//    private var selectedSource: IncomeSource?
//    
//    // MARK: - Dependencies
//    private let getAllActiveSideJobsUseCase: GetActiveSideJobsUseCase
//    private let saveItemUseCase: SaveItemUseCase
//    
//    // MARK: - Initialization
//    init(
//        getAllActiveSideJobsUseCase: GetActiveSideJobsUseCase,
//        saveItemUseCase: SaveItemUseCase
//    ) {
//        self.getAllActiveSideJobsUseCase = getAllActiveSideJobsUseCase
//        self.saveItemUseCase = saveItemUseCase
//    }
//    
//    // MARK: - Public Methods
//    
//    /// Загружает активные подработки
//    func loadData() async {
//        await setLoading(true)
//        defer { Task { await setLoading(false) } }
//        
//        do {
//            let fetchedSideJobs = try await getAllActiveSideJobsUseCase.execute()
//            await updateSideJobs(fetchedSideJobs)
//        } catch {
//            await setError("Failed to load part-time jobs: \(error.localizedDescription)")
//        }
//    }
//    
//    /// Сохраняет новую запись о доходе
//    func saveNewItem(
//        title: String,
//        description: String?,
//        price: Double,
//        date: Date
//    ) async {
//        // Валидация
//        guard let validationError = validateInput(title: title, price: price) else {
//            await self.setError(validationError)
//            return
//        }
//        
//        // Создание записи
//        let entry = IncomeEntry(
//            date: date,
//            jobTitle: title,
//            jobDescription: description,
//            price: price,
//            isPaid: isPaid!,
//            source: selectedSource!
//        )
//        
//        // Сохранение
//        await setLoading(true)
//        defer { Task { await setLoading(false) } }
//        
//        do {
//            try await saveItemUseCase.execute(new: entry)
//            await setSuccess("Income entry saved successfully")
//            resetForm()
//        } catch {
//            await setError("Failed to save income entry: \(error.localizedDescription)")
//        }
//    }
//    
//    /// Выбирает источник дохода по имени
//    func selectSource(sourceName: String) {
//        if sourceName == mainJob.displayName {
//            selectedSource = mainJob
//        } else {
//            selectedSource = sideJobs.first { $0.displayName == sourceName }
//        }
//    }
//    
//    // MARK: - Private Methods
//    
//    /// Валидирует входные данные перед сохранением
//    private func validateInput(title: String, price: Double) -> String? {
//        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
//            return "Income title cannot be empty"
//        }
//        
//        guard price > 0 else {
//            return "Price must be greater than zero"
//        }
//        
//        guard isPaid != nil else {
//            return "Please select income state (Earned/Expected)"
//        }
//        
//        guard selectedSource != nil else {
//            return "Please select income source"
//        }
//        
//        return nil
//    }
//    
//    /// Сбрасывает форму после успешного сохранения
//    private func resetForm() {
//        isPaid = nil
//        selectedSource = nil
//    }
//    
//    /// Обновляет список подработок для отображения
//    private func updateSideJobsForDisplay() {
//        sideJobsForDisplay = sideJobs.map { $0.displayName }
//    }
//    
//    // MARK: - State Management (MainActor)
//    
//    @MainActor
//    private func updateSideJobs(_ jobs: [SideJob]) {
//        self.sideJobs = jobs.map { IncomeSource.sideJob($0) }
//    }
//    
//    @MainActor
//    private func setError(_ message: String) {
//        self.errorMessage = message
//    }
//    
//    @MainActor
//    private func setSuccess(_ message: String) {
//        self.acceptMessage = message
//    }
//    
//    @MainActor
//    private func setLoading(_ loading: Bool) {
//        self.isLoading = loading
//    }
//}

//
//final class AddIncomeViewModel: ObservableObject {
//    @Published var sideJobsForDisplay: [String] = []
//    @Published var errorMessage: String = ""
//    @Published var acceptMessage: String = ""
//    
//    var mainJobName: String {
//        self.mainJob.displayName
//    }
//    private var sideJobs = [IncomeSource]() {
//        didSet {
//            updateAllSourcesForDisplay()
//        }
//    }
//    private var mainJob: IncomeSource = .mainJob
//    
//    private var selectedSource: IncomeSource?
//    
//    var isPaid: Bool?
//    
//    private let getAllActiveSideJobsUseCase: GetActiveSideJobsUseCase
//    private let saveItemUseCase: SaveItemUseCase
//    
//    init(getAllActiveSideJobsUseCase: GetActiveSideJobsUseCase, saveItemUseCase: SaveItemUseCase) {
//        self.getAllActiveSideJobsUseCase = getAllActiveSideJobsUseCase
//        self.saveItemUseCase = saveItemUseCase
//        updateAllSourcesForDisplay()
//    }
//    
//    func loadData() async {
//        do {
//            let sideJobsInData = try await getAllActiveSideJobsUseCase.execute()
//            await MainActor.run {
//                sideJobs = sideJobsInData.map { IncomeSource.sideJob($0) }
//            }
//        } catch {
//            await MainActor.run {
//                self.errorMessage = "Failed to load part-time jobs"
//                sideJobs = []
//            }
//        }
//    }
//    
//    func saveNewItem(title: String, description: String?, price: Double, date: Date) async {
//        guard let isPaid = isPaid else { 
//            self.errorMessage = "Not Selected Income State";
//            return 
//        } 
//        guard let selectedSource = selectedSource else { 
//            self.errorMessage = "Not Selected Income Source"; 
//            return
//        }
//        let entry = IncomeEntry(date: date, 
//                                jobTitle: title, 
//                                jobDescription: description,
//                                price: price, 
//                                isPaid: isPaid,
//                                source: selectedSource)
//        do {
//            try await saveItemUseCase.execute(new: entry)
//            self.acceptMessage = "Save new income entry succesfully"
//        } catch {
//            self.errorMessage = "Failed to save new income entry"
//        }
//    }
//    
//    func selectSource(sourceName: String) {
//        if sourceName == mainJob.displayName {
//            selectedSource = mainJob
//        } else {
//            selectedSource = sideJobs.first { $0.displayName == sourceName }
//        }
//    }
//    
//    private func updateAllSourcesForDisplay() {
//        sideJobsForDisplay = sideJobs.map { $0.displayName }
//    }
//}
