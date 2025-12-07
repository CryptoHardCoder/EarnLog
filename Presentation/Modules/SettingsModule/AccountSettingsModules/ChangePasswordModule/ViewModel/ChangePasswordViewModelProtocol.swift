//
//  ChangePasswordViewModelProtocol.swift
//  EarnLog
//
//  Created by M3 pro on 14/11/2025.
//
import Foundation
import Combine

protocol ChangePasswordViewModelProtocol: AnyObject {
    var currentPasswordValidationPublisher: AnyPublisher<PasswordValidationState, Never> { get }
    var newPasswordValidationPublisher: AnyPublisher<PasswordValidationState, Never> { get }
    var confirmPasswordValidationPublisher: AnyPublisher<ConfirmPasswordValidationState, Never> { get }
    var isSubmitEnabledPublisher: AnyPublisher<Bool, Never> { get }

    func validateCurrentPassword(_ password: String)
    func validateNewPassword(_ password: String)
    func validateConfirmPassword(_ password: String, against newPassword: String)
    func submit(oldPassword: String, newPassword: String, confirmPassword: String) async throws
}


struct PasswordValidationState: Equatable {
    let hasMinLength: Bool
    let hasUppercase: Bool
    let hasDigit: Bool
    let hasSpecialSymbol: Bool

    var isValid: Bool {
        hasMinLength && hasUppercase && hasDigit && hasSpecialSymbol
    }

    init(
        hasMinLength: Bool = false,
        hasUppercase: Bool = false,
        hasDigit: Bool = false,
        hasSpecialSymbol: Bool = false
    ) {
        self.hasMinLength = hasMinLength
        self.hasUppercase = hasUppercase
        self.hasDigit = hasDigit
        self.hasSpecialSymbol = hasSpecialSymbol
    }
}

struct ConfirmPasswordValidationState: Equatable {
    let isMatching: Bool

    init(isMatching: Bool = false) {
        self.isMatching = isMatching
    }
}


    // MARK: - Errors
enum PasswordValidationError: Error, LocalizedError {
    case currentPasswordInvalid
    case newPasswordInvalid
    case passwordsDoNotMatch
    case passwordEqualToOld

    var errorDescription: String? {
        switch self {
            case .currentPasswordInvalid:
                return "Current password doesn't meet requirements"
            case .newPasswordInvalid:
                return "New password doesn't meet requirements"
            case .passwordsDoNotMatch:
                return "Passwords do not match"
            case .passwordEqualToOld:
                return "New password must be different from current password"
        }
    }
}

