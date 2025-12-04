//
//  UpdateUserNameUseCase.swift
//  EarnLog
//
//  Created by M3 pro on 09/11/2025.
//
import Foundation

protocol UpdateUserNameUseCase {
    func execute(_ newName: String) async throws
}

final class UpdateUserNameUseCaseImpl: UpdateUserNameUseCase {

    private let userManager: UserManagerRepository

    init(userManager: UserManagerRepository) {
        self.userManager = userManager
    }

    func execute(_ newName: String) async throws {
        try await userManager.updateUserName(newName)
    }
}
