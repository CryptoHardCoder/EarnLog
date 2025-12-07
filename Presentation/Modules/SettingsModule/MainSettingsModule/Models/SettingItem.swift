//
//  SettingItem.swift
//  EarnLog
//
//  Created by M3 pro on 26/10/2025.
//

import Foundation
import UIKit

struct SettingItem: Hashable {
    let id = UUID()
    let title: String
    let icon: UIImage?
    let destination: SettingsDestination
    let interactionType: SettingInteractionType

    init(title: String, icon: UIImage?, destination: SettingsDestination, interactionType: SettingInteractionType) {
        self.title = title
        self.icon = icon
        self.destination = destination
        self.interactionType = interactionType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SettingItem, rhs: SettingItem) -> Bool {
        lhs.id == rhs.id
    }
}
