//
//  UserPreferencesRepository.swift
//  EarnLog
//
//  Created by M3 pro on 12/10/2025.
//
import Foundation

protocol GetUserMonthlyGoalUseCase {
    func execute() async -> Double?
}

final class GetUserMonthlyGoalUseCaseImpl: GetUserMonthlyGoalUseCase {
    private let userManager: UserManagerRepository

    init(userManager: UserManagerRepository){
        self.userManager = userManager
    }

    func execute() async -> Double?{
        try? await userManager.getUserInfo().goal
    }
}
//
//protocol UserMonthlyGoalUseCase {
//    var monthlyGoal: Double { get set }
//}
//
//final class UserMonthlyGoalUseCaseImpl: UserMonthlyGoalUseCase {
//    init(){
//        UserDefaults.standard.removeObject(forKey: Keys.monthlyGoal)
//        UserDefaults.standard.synchronize()
//    }
//
//    private enum Keys {
//        static let monthlyGoal = "monthlyGoal"
//    }
//
//    var monthlyGoal: Double {
//        get { UserDefaults.standard.double(forKey: Keys.monthlyGoal) }
//        set { UserDefaults.standard.set(newValue, forKey: Keys.monthlyGoal) }
//    }
//
//}

