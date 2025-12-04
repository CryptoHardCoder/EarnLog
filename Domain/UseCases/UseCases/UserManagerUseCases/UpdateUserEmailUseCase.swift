//
//  UpdateUserEmailUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 09/11/2025.
//
import Foundation

protocol UpdateUserEmailUseCase {
    func execute(_ newEmail: String) async throws
}

final class UpdateUserEmailUseCaseImpl: UpdateUserEmailUseCase {

    private let userManager: UserManagerRepository

    init(userManager: UserManagerRepository) {
        self.userManager = userManager
    }

    func execute(_ newEmail: String) async throws {
        try await userManager.updateUserEmail(newEmail)
    }
}
