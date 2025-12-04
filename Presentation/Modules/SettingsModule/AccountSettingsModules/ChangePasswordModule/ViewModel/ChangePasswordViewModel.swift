//
//  ChangePasswordViewModel.swift
//  EarnLog
//
//  Created by M3 pro on 14/11/2025.
//
import Foundation
import Combine

final class ChangePasswordViewModel: ChangePasswordViewModelProtocol {

        // MARK: - Published Properties

    var currentPasswordValidationPublisher: AnyPublisher<PasswordValidationState, Never> {
        $currentPasswordValidationState.eraseToAnyPublisher()
    }

    var newPasswordValidationPublisher: AnyPublisher<PasswordValidationState, Never> {
        $newPasswordValidationState.eraseToAnyPublisher()
    }

    var confirmPasswordValidationPublisher: AnyPublisher<ConfirmPasswordValidationState, Never> {
        $confirmPasswordValidationState.eraseToAnyPublisher()
    }

    var isSubmitEnabledPublisher: AnyPublisher<Bool, Never> {
        $isSubmitEnabled.eraseToAnyPublisher()
    }

    @Published private var currentPasswordValidationState = PasswordValidationState()
    @Published private var newPasswordValidationState = PasswordValidationState()
    @Published private var confirmPasswordValidationState = ConfirmPasswordValidationState()
    @Published private var isSubmitEnabled = false

        // MARK: - Private Properties

    private let updateUserPasswordUseCase: any UpdateUserPasswordUseCase
    private let validator: PasswordValidator
    private var cancellables = Set<AnyCancellable>()

        // MARK: - Initialization

    init(
        updateUserPasswordUseCase: any UpdateUserPasswordUseCase,
        validator: PasswordValidator = DefaultPasswordValidator()
    ) {
        self.updateUserPasswordUseCase = updateUserPasswordUseCase
        self.validator = validator
        setupValidationObservers()
    }

        // MARK: - Private Methods

    private func setupValidationObservers() {
        Publishers.CombineLatest3(
            $currentPasswordValidationState,
            $newPasswordValidationState,
            $confirmPasswordValidationState
        )
        .map { current, new, confirm in
            current.isValid && new.isValid && confirm.isMatching
        }
        .assign(to: &$isSubmitEnabled)
    }

        // MARK: - Public Methods

    func validateCurrentPassword(_ password: String) {
        currentPasswordValidationState = validator.validate(password)
    }

    func validateNewPassword(_ password: String) {
        newPasswordValidationState = validator.validate(password)
    }

    func validateConfirmPassword(_ password: String, against newPassword: String) {
        confirmPasswordValidationState = ConfirmPasswordValidationState(
            isMatching: password == newPassword && !password.isEmpty
        )
    }

    func submit(oldPassword: String, newPassword: String, confirmPassword: String) async throws {

        let currentValidation = validator.validate(oldPassword)
        let newValidation = validator.validate(newPassword)

        guard currentValidation.isValid else {
            throw PasswordUIError.validation(.currentPasswordInvalid)
        }

        guard newValidation.isValid else {
            throw PasswordUIError.validation(.newPasswordInvalid)
        }

        guard newPassword == confirmPassword else {
            throw PasswordUIError.validation(.passwordsDoNotMatch)
        }

        guard oldPassword != newPassword else {
            throw PasswordUIError.validation(.passwordEqualToOld)
        }

        do {
            try await updateUserPasswordUseCase.execute(oldPassword, newPassword: newPassword)
        } catch {
            throw PasswordUIError.server("Будущая ошибка которого надо написать use case")
        }
    }
}


    // MARK: - Password Validator

protocol PasswordValidator {
    func validate(_ password: String) -> PasswordValidationState
}

final class DefaultPasswordValidator: PasswordValidator {

    private let minLength = 8
    private let uppercaseCharacters = CharacterSet.uppercaseLetters
    private let digitCharacters = CharacterSet.decimalDigits
    private let specialCharacters = CharacterSet(charactersIn: "!?.,@#$%^&*:/")

    func validate(_ password: String) -> PasswordValidationState {
        let hasMinLength = password.count >= minLength
        let hasUppercase = password.unicodeScalars.contains { uppercaseCharacters.contains($0) }
        let hasDigit = password.unicodeScalars.contains { digitCharacters.contains($0) }
        let hasSpecialSymbol = password.unicodeScalars.contains { specialCharacters.contains($0) }

        return PasswordValidationState(
            hasMinLength: hasMinLength,
            hasUppercase: hasUppercase,
            hasDigit: hasDigit,
            hasSpecialSymbol: hasSpecialSymbol
        )
    }
}

enum PasswordUIError: Error {
    case validation(PasswordValidationError)
    case server(String)
}

