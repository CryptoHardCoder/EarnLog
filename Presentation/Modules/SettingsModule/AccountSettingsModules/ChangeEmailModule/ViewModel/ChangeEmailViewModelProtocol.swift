//
//  ChangeEmailViewModelProtocol.swift
//  EarnLog
//
//  Created by M3 pro on 16/11/2025.
//
import Foundation
import Combine

protocol ChangeEmailViewModelProtocol {

    var isEmailValidPublisher: AnyPublisher<Bool, Never> { get }
    
    var email: String { get set }

    func submitChangeEmail() async

    func isValidEmail(_ email: String) -> Bool
}
