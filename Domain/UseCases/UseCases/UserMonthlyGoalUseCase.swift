//
//  UserPreferencesRepository.swift
//  EarnLog
//
//  Created by M3 pro on 12/10/2025.
//
import Foundation

protocol UserMonthlyGoalUseCase {
    var monthlyGoal: Double { get set }
}

final class UserMonthlyGoalUseCaseImpl: UserMonthlyGoalUseCase {
    private enum Keys {
        static let monthlyGoal = "monthlyGoal"
    }
    
    var monthlyGoal: Double {
        get { UserDefaults.standard.double(forKey: Keys.monthlyGoal) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.monthlyGoal) }
    }
    
    init(){
        print("UserMonthlyGoalUseCaseImpl inited")
        UserDefaults.standard.removeObject(forKey: Keys.monthlyGoal)
        UserDefaults.standard.synchronize()
    }
}
