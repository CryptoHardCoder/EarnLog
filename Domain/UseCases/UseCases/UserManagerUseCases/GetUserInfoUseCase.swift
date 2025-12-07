//
//  GetUserInfoUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 06/11/2025.
//
import Foundation

protocol GetUserInfoUseCase {
    func execute() async throws -> UserProfile
}

final class GetUserInfoUseCaseImpl: GetUserInfoUseCase {

    private let userManager: UserManagerRepository

    init(userManager: UserManagerRepository) {
        self.userManager = userManager
    }

    func execute() async throws -> UserProfile {
        try await userManager.getUserInfo()
    }
}
