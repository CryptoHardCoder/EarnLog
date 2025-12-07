//
//  SettingsViewModel.swift
//  EarnLog
//
//  Created by M3 pro on 12/08/2025.
//
import Foundation
import Combine

final class SettingsViewModel: SettingsViewModelProtocol {

    private let settingsDataBuilder: SettingsDataBuilder

    init(settingsDataBuilder: SettingsDataBuilder) {
        self.settingsDataBuilder = settingsDataBuilder
    }

    lazy var settingsData = {
        self.settingsDataBuilder.buildMainSettings()
    }()
}
