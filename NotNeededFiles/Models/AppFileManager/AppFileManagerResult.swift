////
////  AppFileManagerResult.swift
////  EarnLog
////
////  Created by M3 pro on 21/09/2025.
////
//
//
////enum AppFileManagerResult<T> {
////    case success(T)
////    case failure(AppFileManagerError)
////    
////    var isSuccess: Bool {
////        switch self {
////            case .success: return true
////            case .failure: return false
////        }
////    }
////    
////    var error: AppFileManagerError? {
////        switch self{
////            case .success: return nil
////            case .failure(let error): return error
////        }
////    }
////    
////    
////}
//import Combine
//import Foundation
//
//// MARK: - БЕЗ Result - чистый Combine подход
//
//class AppFileManagerCombine: ObservableObject {
//    
//    @Published var allItems: [IncomeEntry] = []
//    
//    private var cancellables = Set<AnyCancellable>()
//    private let saveSubject = PassthroughSubject<Void, Never>()
//    
//    // MARK: - Combine Publishers
//    
//    /// Загружает элементы из JSON файла
//    func loadItemsPublisher() -> AnyPublisher<[IncomeEntry], AppFileManagerError> {
//        return Future<[IncomeEntry], AppFileManagerError> { [weak self] promise in
//            guard let self = self else {
//                promise(.failure(.invalidData))
//                return
//            }
//            
//            DispatchQueue.global(qos: .background).async {
//                do {
//                    guard self.fileManager.fileExists(atPath: self.jsonFileURL.path) else {
//                        promise(.failure(.fileNotFound(fileName: self.jsonFileName)))
//                        return
//                    }
//                    
//                    let data = try Data(contentsOf: self.jsonFileURL)
//                    let items = try JSONDecoder().decode([IncomeEntry].self, from: data)
//                    
//                    DispatchQueue.main.async {
//                        self.allItems = items
//                    }
//                    
//                    promise(.success(items))
//                } catch let decodingError as DecodingError {
//                    promise(.failure(.jsonDecodingError(underlying: decodingError)))
//                } catch {
//                    promise(.failure(.loadError(underlying: error)))
//                }
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    /// Сохраняет элементы в JSON файл
//    func saveItemsPublisher() -> AnyPublisher<Void, AppFileManagerError> {
//        return Future<Void, AppFileManagerError> { [weak self] promise in
//            guard let self = self else {
//                promise(.failure(.invalidData))
//                return
//            }
//            
//            do {
//                let data = try JSONEncoder().encode(self.allItems)
//                try data.write(to: self.jsonFileURL)
//                promise(.success(()))
//            } catch let encodingError as EncodingError {
//                promise(.failure(.jsonEncodingError(underlying: encodingError)))
//            } catch {
//                promise(.failure(.saveError(underlying: error)))
//            }
//        }
//        .subscribe(on: DispatchQueue.global(qos: .background))
//        .receive(on: DispatchQueue.main)
//        .eraseToAnyPublisher()
//    }
//    
//    /// Добавляет новый элемент
//    func addItem(_ item: IncomeEntry) -> AnyPublisher<Void, AppFileManagerError> {
//        allItems.append(item)
//        return saveItemsPublisher()
//    }
//    
//    /// Удаляет элемент по ID
//    func deleteItem(withId id: UUID) -> AnyPublisher<Void, AppFileManagerError> {
//        guard let index = allItems.firstIndex(where: { $0.id == id }) else {
//            return Fail(error: AppFileManagerError.itemNotFound(id: id))
//                .eraseToAnyPublisher()
//        }
//        
//        allItems.remove(at: index)
//        return saveItemsPublisher()
//    }
//    
//    /// Обновляет элемент
//    func updateItem(id: UUID, newPrice: Double) -> AnyPublisher<Void, AppFileManagerError> {
//        guard let index = allItems.firstIndex(where: { $0.id == id }) else {
//            return Fail(error: AppFileManagerError.itemNotFound(id: id))
//                .eraseToAnyPublisher()
//        }
//        
//        // Обновляем элемент
//        let currentItem = allItems[index]
//        allItems[index] = IncomeEntry(
//            date: currentItem.date,
//            car: currentItem.jobDescription,
//            price: newPrice,
//            isPaid: currentItem.isPaid,
//            source: currentItem.source
//        )
//        
//        return saveItemsPublisher()
//    }
//    
//    /// Автосохранение с debounce
//    func setupAutoSave() {
//        saveSubject
//            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
//            .flatMap { [weak self] _ -> AnyPublisher<Void, Never> in
//                guard let self = self else {
//                    return Empty().eraseToAnyPublisher()
//                }
//                
//                return self.saveItemsPublisher()
//                    .catch { error -> Empty<Void, Never> in
//                        // Логируем ошибку, но не прерываем поток
//                        print("Auto-save error: \(error.localizedDescription)")
//                        return Empty()
//                    }
//                    .eraseToAnyPublisher()
//            }
//            .sink { }
//            .store(in: &cancellables)
//    }
//    
//    /// Загрузка или создание данных
//    func loadOrCreateData() -> AnyPublisher<[IncomeEntry], Never> {
//        return loadItemsPublisher()
//            .catch { [weak self] error -> AnyPublisher<[IncomeEntry], AppFileManagerError> in
//                guard let self = self else {
//                    return Fail(error: .invalidData).eraseToAnyPublisher()
//                }
//                
//                // Если файл не найден - создаем sample data
//                if case .fileNotFound = error {
//                    self.createSampleData()
//                    return Just(self.allItems)
//                        .setFailureType(to: AppFileManagerError.self)
//                        .eraseToAnyPublisher()
//                }
//                
//                return Fail(error: error).eraseToAnyPublisher()
//            }
//            .catch { error -> Just<[IncomeEntry]> in
//                // В крайнем случае возвращаем пустой массив
//                print("Failed to load data: \(error.localizedDescription)")
//                return Just([])
//            }
//            .eraseToAnyPublisher()
//    }
//}
//
//// MARK: - ViewModel с Combine
//
//class IncomeViewModelCombine: ObservableObject {
//    
//    @Published var items: [IncomeEntry] = []
//    @Published var errorMessage: String?
//    @Published var isLoading = false
//    
//    private let fileManager: AppFileManagerCombine
//    private var cancellables = Set<AnyCancellable>()
//    
//    init(fileManager: AppFileManagerCombine) {
//        self.fileManager = fileManager
//        setupBindings()
//    }
//    
//    private func setupBindings() {
//        // Автоматически обновляем items при изменении fileManager.allItems
//        fileManager.$allItems
//            .assign(to: \.items, on: self)
//            .store(in: &cancellables)
//    }
//    
//    func loadItems() {
//        isLoading = true
//        errorMessage = nil
//        
//        fileManager.loadOrCreateData()
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    self?.isLoading = false
//                },
//                receiveValue: { [weak self] items in
//                    self?.items = items
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func addItem(_ item: IncomeEntry) {
//        fileManager.addItem(item)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = error.localizedDescription
//                    }
//                },
//                receiveValue: { _ in
//                    // Success - items автоматически обновятся через binding
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func deleteItem(id: UUID) {
//        fileManager.deleteItem(withId: id)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = error.localizedDescription
//                    }
//                },
//                receiveValue: { _ in
//                    // Success - items автоматически обновятся
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func updateItem(id: UUID, newPrice: Double) {
//        fileManager.updateItem(id: id, newPrice: newPrice)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = error.localizedDescription
//                    }
//                },
//                receiveValue: { _ in
//                    // Success
//                }
//            )
//            .store(in: &cancellables)
//    }
//}
//
//// MARK: - Для сравнения: КОМБО подход (Result + Combine)
//
//extension AppFileManagerCombine {
//    
//    /// Если все-таки хочешь использовать Result с Combine
//    func loadItemsResultPublisher() -> AnyPublisher<Result<[IncomeEntry], AppFileManagerError>, Never> {
//        return loadItemsPublisher()
//            .map { Result.success($0) }
//            .catch { error in
//                Just(Result.failure(error))
//            }
//            .eraseToAnyPublisher()
//    }
//}
//
//// MARK: - Сравнение подходов
//
///*
//┌─────────────────────────────────────────────────────────────────┐
//│                    БЕЗ COMBINE (Result)                        │
//├─────────────────────────────────────────────────────────────────┤
//│ ✅ Простая обработка ошибок через switch                        │
//│ ✅ Синхронные операции легко понять                            │  
//│ ❌ Много boilerplate кода для async операций                   │
//│ ❌ Сложно комбинировать операции                               │
//│ ❌ Ручное управление состоянием UI                             │
//└─────────────────────────────────────────────────────────────────┘
//
//┌─────────────────────────────────────────────────────────────────┐
//│                     С COMBINE (Publishers)                     │
//├─────────────────────────────────────────────────────────────────┤
//│ ✅ Автоматическое управление состоянием через @Published        │
//│ ✅ Легкое комбинирование операций (map, flatMap, catch)        │
//│ ✅ Встроенный error handling через completion                   │
//│ ✅ Debouncing и другие операторы из коробки                    │
//│ ✅ Reactive programming                                         │
//│ ❌ Больше сложности для простых операций                       │
//│ ❌ Кривая обучения Combine                                      │
//└─────────────────────────────────────────────────────────────────┘
//
//┌─────────────────────────────────────────────────────────────────┐
//│                   КОМБО (Result + Combine)                     │
//├─────────────────────────────────────────────────────────────────┤
//│ ✅ Можно использовать оба подхода                              │
//│ ❌ Избыточность - Combine уже предоставляет error handling     │
//│ ❌ Больше кода без особых преимуществ                          │
//└─────────────────────────────────────────────────────────────────┘
//*/
