//
//  SetUserMonthlyGoalUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 09/11/2025.
//
import Foundation

protocol SetUserMonthlyGoalUseCase {
    func execute() async throws
}

final class SetUserMonthlyGoalUseCaseImpl: SetUserMonthlyGoalUseCase {

    private let userManager: UserManagerRepository

    init(userManager: UserManagerRepository) {
        self.userManager = userManager
    }
    
    func execute() async throws {
        try await userManager.setUserMonthlyGoal()
    }
    

}
