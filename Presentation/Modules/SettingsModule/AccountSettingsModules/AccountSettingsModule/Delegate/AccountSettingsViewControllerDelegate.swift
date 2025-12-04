//
//  Untitled.swift
//  EarnLog
//
//  Created by M3 pro on 13/11/2025.
//
import Foundation

protocol AccountSettingsViewControllerDelegate: AnyObject {
    func accountSettingViewController(_ controller: AccountSettingsViewController,
                                      didSelect destination: SettingsDestination)
    func accountSettingsViewControllerDidFinish(_ controller: AccountSettingsViewController)
}
