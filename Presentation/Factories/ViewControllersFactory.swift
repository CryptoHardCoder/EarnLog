//
//  ViewControllersFactory.swift
//  EarnLog
//
//  Created by M3 pro on 03/11/2025.
//
import UIKit

final class ViewControllersFactory: ViewControllersFactoryProtocol {

    private let viewModelsFactory: ViewModelFactory

    init(viewModelsFactory: ViewModelFactory) {
        self.viewModelsFactory = viewModelsFactory
    }

    func makeMainViewController() -> UIViewController{
        let viewModel = viewModelsFactory.makeMainViewModel()
        return MainViewController(viewModel: viewModel)
    }

    func makeAddIncomeViewController() -> UIViewController {
        let viewModel = viewModelsFactory.makeAddIncomeViewModel()
        return AddIncomeViewController(viewModel: viewModel)
    }

    func makeSettingsViewController() -> SettingsViewController {
        let viewModel = viewModelsFactory.makeSettingsViewModel()
        return SettingsViewController(viewModel: viewModel)
    }

    func makeAccountSettingsViewController() -> AccountSettingsViewController {
        let viewModel = viewModelsFactory.makeAccountSettingsViewModel()
        return AccountSettingsViewController(viewModel: viewModel)
    }

    func makeChangePasswordViewController() -> ChangePasswordViewController {
        let viewModel = viewModelsFactory.makeChangePasswordViewModel()
        return ChangePasswordViewController(viewModel: viewModel)
    }

    func makeChangeEmailViewController() -> ChangeEmailViewController {
        let viewModel = viewModelsFactory.makeChangeEmailViewModel()
        return ChangeEmailViewController(viewModel: viewModel)
    }

    func makeChangeAppearanceViewController() -> ChangeAppearanceViewController {
        let viewModel = viewModelsFactory.makeChangeAppearanceViewModel()
        return ChangeAppearanceViewController(viewModel: viewModel)
    }
}
