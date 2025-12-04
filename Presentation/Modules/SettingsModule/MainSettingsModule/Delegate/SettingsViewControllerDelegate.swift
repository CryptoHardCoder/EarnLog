//
//  SettingsViewControllerDelegate.swift
//  EarnLog
//
//  Created by M3 pro on 04/11/2025.
//
import Foundation

protocol SettingsViewControllerDelegate: AnyObject {
    func settingsViewController(_ controller: SettingsViewController, 
                               didSelect destination: SettingsDestination)
}
