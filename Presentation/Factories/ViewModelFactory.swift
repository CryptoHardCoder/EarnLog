//
//  ViewModelFactory.swift
//  EarnLog
//
//  Created by M3 pro on 03/11/2025.
//
import Foundation

final class ViewModelFactory: ViewModelFactoryProtocol {

    private let dependencies: AppDependencies

    private let settingsDataBuilder: SettingsDataBuilder

    init(dependencies: AppDependencies = .shared,
         settingsDataBuilder: SettingsDataBuilder = SettingsDataBuilder()) {
        self.dependencies = dependencies
        self.settingsDataBuilder = settingsDataBuilder
    }

    func makeMainViewModel() -> any MainViewModelProtocol {
        MainViewModel(getCurrentMonthItemsUseCase: dependencies.getCurrentMonthItemsUseCase,
                      userMonthlyGoalUseCase: dependencies.userMonthlyGoalUseCase)
    }

    func makeAddIncomeViewModel() -> any AddIncomeViewModelProtocol {
       AddIncomeViewModel(getAllActiveSideJobsUseCase: dependencies.getActiveSideJobsUseCase,
                          saveItemUseCase: dependencies.saveItemUseCase)
    }

    func makeSettingsViewModel() -> any SettingsViewModelProtocol {
        SettingsViewModel(settingsDataBuilder: settingsDataBuilder)
    }

    func makeAccountSettingsViewModel() -> any AccountSettingsViewModelProtocol {
        AccountSettingsViewModel(getUserInfoUseCase: dependencies.getUserInfoUseCase,
                                 updateUserNameUseCase: dependencies.updateUserNameUseCase,
                                 updateUserEmailUseCase: dependencies.updateUserEmailUseCase,
                                 updateUserPasswordUseCase: dependencies.updateUserPasswordUseCase,
                                 settingsDataBuilder: settingsDataBuilder)
    }

    func makeChangePasswordViewModel() -> any ChangePasswordViewModelProtocol {
        ChangePasswordViewModel(updateUserPasswordUseCase: dependencies.updateUserPasswordUseCase)
    }

    func makeChangeEmailViewModel() -> any ChangeEmailViewModelProtocol {
        ChangeEmailViewModel(updateUserEmailUseCase: dependencies.updateUserEmailUseCase)
    }

    func makeChangeAppearanceViewModel() -> any ChangeAppearanceViewModelProtocol {
        ChangeAppearanceViewModel()
    }

}
