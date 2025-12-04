//
//  AccountSettingsViewModel.swift
//  EarnLog
//
//  Created by M3 pro on 05/11/2025.
//
import Foundation
import UIKit
import Combine

final class AccountSettingsViewModel: AccountSettingsViewModelProtocol {

    var settingItemsPublisher: AnyPublisher<[SettingItem], Never> { $settingItems.eraseToAnyPublisher() }

    var userInfoPublisher: AnyPublisher<UserProfile?, Never> { $userInfo.eraseToAnyPublisher() }

    @Published private var settingItems: [SettingItem] = []

    @Published private var userInfo: UserProfile? = nil

    private let getUserInfoUseCase: GetUserInfoUseCase
    private let updateUserNameUseCase: UpdateUserNameUseCase
    private let updateUserEmailUseCase: UpdateUserEmailUseCase
    private let updateUserPasswordUseCase: UpdateUserPasswordUseCase
    private let settingsDataBuilder: SettingsDataBuilder

    init(getUserInfoUseCase: GetUserInfoUseCase,
         updateUserNameUseCase: UpdateUserNameUseCase,
         updateUserEmailUseCase: UpdateUserEmailUseCase,
         updateUserPasswordUseCase: UpdateUserPasswordUseCase,
         settingsDataBuilder: SettingsDataBuilder) {
        self.getUserInfoUseCase = getUserInfoUseCase
        self.updateUserNameUseCase = updateUserNameUseCase
        self.updateUserEmailUseCase = updateUserEmailUseCase
        self.updateUserPasswordUseCase = updateUserPasswordUseCase
        self.settingsDataBuilder = settingsDataBuilder
        loadData()
    }

    private func loadData(){
        getSettingsData()
        Task {
            do {
                userInfo = try await getUserInfoUseCase.execute()
            } catch {
                userInfo = nil
            }
        }
    }

    private func getSettingsData() {
        settingItems = settingsDataBuilder.buildAccountSettingsData()
    }

    func editName(newName: String) {
        Task{
            try await updateUserNameUseCase.execute(newName)
        }
    }

    private func editNameSetting() {

    }

    private func editEmailSetting(){

    }

    private func changePasswordNameSetting(){

    }


}
