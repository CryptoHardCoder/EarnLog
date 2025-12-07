//
//  UserManager.swift
//  EarnLog
//
//  Created by M3 pro on 09/11/2025.
//
import Foundation

protocol UserManagerRepository {
    func saveUser() async throws
    func getUserInfo() async throws -> UserProfile
    func updateUserName(_ newName: String) async throws
    func updateUserEmail(_ newEmail: String) async throws
    func updateUserPassword(_ oldPassword: String, newPassword: String) async throws
    func setUserMonthlyGoal() async throws
}
