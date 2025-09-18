//
//  SettingsViewModel.swift
//  EarnLog
//
//  Created by M3 pro on 12/08/2025.
//

import Foundation
import UIKit

final class SettingsViewModel: MemoryTrackable {
    var settings: [Settings] {
        Settings.allCases
    }
    
    private let factory = SettingsFactory()
    
    init() {
        trackCreation()
    }
    
    func makeViewController(for setting: Settings) -> UIViewController {
        return factory.makeViewController(for: setting)
    }
    
    
    deinit {
        trackDeallocation() // для анализа на memory leaks
    }
}
