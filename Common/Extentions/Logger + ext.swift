//
//  Logger + ext.swift
//  EarnLog
//
//  Created by M3 pro on 16/11/2025.
import Foundation
import OSLog

extension Logger {

        // MARK: - Log Levels

    enum LogLevel: String, CaseIterable {
        case trace
        case debug
        case info
        case notice
        case warning
        case error
        case critical
        case fault

        var emoji: String {
            switch self {
                case .trace: return "🔍"
                case .debug: return "🐛"
                case .info: return "ℹ️"
                case .notice: return "📌"
                case .warning: return "⚠️"
                case .error: return "❌"
                case .critical: return "🔥"
                case .fault: return "💥"
            }
        }
    }

        // MARK: - Log Category

    enum LogCategory: String {
        case network = "Network"
        case database = "Database"
        case ui = "UI"
        case business = "Business"
        case coordinator = "Coordinator"
        case viewModel = "ViewModel"
        case useCase = "UseCase"
        case repository = "Repository"
        case general = "General"
        case lifecycle = "Lifecycle"
        case performance = "Performance"
        case security = "Security"
    }

    static func loggerFormattedMessage(
        logLevel: LogLevel,
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        let filename = (file as NSString).lastPathComponent
        return "\(logLevel.emoji) \(message) || file: \(filename):\(line) || func: \(function)"
    }



        /// Создает Logger для конкретной категории
    private static func make(category: LogCategory, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app") -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }

        /// Логгер по умолчанию (General)
    static let `default` = Logger.make(category: .general)

        /// Преднастроенные логгеры для каждой категории
    static let network = Logger.make(category: .network)
    static let database = Logger.make(category: .database)
    static let ui = Logger.make(category: .ui)
    static let business = Logger.make(category: .business)
    static let coordinator = Logger.make(category: .coordinator)
    static let viewModel = Logger.make(category: .viewModel)
    static let useCase = Logger.make(category: .useCase)
    static let repository = Logger.make(category: .repository)
    static let lifecycle = Logger.make(category: .lifecycle)
    static let performance = Logger.make(category: .performance)
    static let security = Logger.make(category: .security)

}

