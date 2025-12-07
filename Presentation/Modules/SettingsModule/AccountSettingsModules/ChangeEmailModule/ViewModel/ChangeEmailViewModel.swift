//
//  ChangeEmailViewModel.swift
//  EarnLog
//
//  Created by M3 pro on 16/11/2025.
//
import Foundation
import OSLog
import Combine

final class ChangeEmailViewModel: ChangeEmailViewModelProtocol {

    @Published var email: String = ""

    var isEmailValidPublisher: AnyPublisher<Bool, Never> {
        $email
            .map{ self.isValidEmail($0) }
            .eraseToAnyPublisher()
    }

    private let updateUserEmailUseCase: any UpdateUserEmailUseCase

    init(updateUserEmailUseCase: any UpdateUserEmailUseCase) {
        self.updateUserEmailUseCase = updateUserEmailUseCase
    }

    func submitChangeEmail() async {
        guard self.isValidEmail(email) else { return }

        do {
            try await updateUserEmailUseCase.execute(email)
        } catch {
//            errorMessage = "Не удалось изменить email"
        }

    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
}
