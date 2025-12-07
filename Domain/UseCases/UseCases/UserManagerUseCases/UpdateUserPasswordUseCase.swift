//
//  UpdateUserPasswordUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 09/11/2025.
//
import Foundation

protocol UpdateUserPasswordUseCase {
    func execute(_ oldPassword: String, newPassword: String) async throws
}

final class UpdateUserPasswordUseCaseImpl: UpdateUserPasswordUseCase {

    private let userManager: UserManagerRepository

    init(userManager: UserManagerRepository) {
        self.userManager = userManager
    }

    func execute(_ oldPassword: String, newPassword: String) async throws {
        try await userManager.updateUserPassword(oldPassword, newPassword: newPassword)
    }
}

