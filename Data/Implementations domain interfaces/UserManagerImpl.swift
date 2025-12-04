//
//  UserManagerImpl.swift
//  EarnLog
//
//  Created by M3 pro on 09/11/2025.
//
import Foundation

final class UserManagerImpl: UserManagerRepository {

    func saveUser() async throws {

    }
    
    func getUserInfo() async throws -> UserProfile {
        return UserProfile(id: UUID().uuidString, name: "John",
                           email: "EarnLog@mail.ru",
                           language: "En",
                           createdAt: .now,
                           settings: .init(theme: .light, notificationsEnabled: .random()),
                           plan: .free)
    }
    
    func updateUserName(_ newName: String) async throws {

    }
    
    func updateUserEmail(_ newEmail: String) async throws {

    }

    func updateUserPassword(_ oldPassword: String, newPassword: String) async throws {
        
    }


    func setUserMonthlyGoal() async throws {

    }

}
