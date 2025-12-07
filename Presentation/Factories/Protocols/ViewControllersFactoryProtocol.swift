//
//  Untitled.swift
//  EarnLog
//
//  Created by M3 pro on 03/11/2025.
//
import Foundation
import UIKit

protocol ViewControllersFactoryProtocol {
    func makeMainViewController() -> UIViewController
    func makeAddIncomeViewController() -> UIViewController
    func makeSettingsViewController() -> SettingsViewController
    func makeAccountSettingsViewController() -> AccountSettingsViewController
    func makeChangePasswordViewController() -> ChangePasswordViewController
    func makeChangeEmailViewController() -> ChangeEmailViewController

    func makeChangeAppearanceViewController() -> ChangeAppearanceViewController

}
