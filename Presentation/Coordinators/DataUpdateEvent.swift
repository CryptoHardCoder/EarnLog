//
//  DataUpdateEvent.swift
//  EarnLog
//
//  Created by M3 pro on 18/10/2025.
//

import Combine

/// События, которые могут происходить в приложении
enum DataUpdateEvent {
    case newIncomeEntryCreated
    case incomeEntryUpdated(id: String)
    case incomeEntryDeleted(id: String)
    case goalUpdated
    case statisticsNeedRefresh
}

/// Координатор для синхронизации данных между ViewModels
/// Находится на Presentation слое и не нарушает чистоту архитектуры
final class DataUpdateCoordinator {
    
    // Singleton для удобного доступа
    static let shared = DataUpdateCoordinator()
    
    // Publisher, на который подписываются все ViewModels
    private let eventSubject = PassthroughSubject<DataUpdateEvent, Never>()
    
    var events: AnyPublisher<DataUpdateEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    private init() {}
    
    // Метод для публикации событий
    private func publish(event: DataUpdateEvent) {
        eventSubject.send(event)
    }
    
    // Удобные методы для частых событий
    func notifyNewIncomeEntryCreated() {
        publish(event: .newIncomeEntryCreated)
    }
    
    func notifyIncomeEntryUpdated(id: String) {
        publish(event: .incomeEntryUpdated(id: id))
    }
    
    func notifyIncomeEntryDeleted(id: String) {
        publish(event: .incomeEntryDeleted(id: id))
    }
    
    func notifyGoalUpdated() {
        publish(event: .goalUpdated)
    }
    
    func notifyStatisticsNeedRefresh() {
        publish(event: .statisticsNeedRefresh)
    }
}
