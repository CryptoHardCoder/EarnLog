//
//  SettingDestination.swift
//  EarnLog
//
//  Created by M3 pro on 18/08/2025.
//
import UIKit

enum SettingsDestination {
    case avatar
    case account([AccountSettings])
    case security([SecuritySettings])
    case currency
    case goals
    case sources
    case appearance([AppearanceSettings])
    case notifications
    case help
    case rateApp
    case logOut

    enum AccountSettings {
        case editName, updateEmail, updatePassword
    }

    enum SecuritySettings {
        case setPIN, setFaceID
    }

    enum AppearanceSettings {
        case system, dark, light
    }


//    func getSettingItems() -> [SettingItem]? {
//        switch self {
//            case .account:
//                return [
//                    SettingItem(title: "Edit Your Name",
//                                icon: nil,
//                                interactionType: .alertWithInput(currentValue: <#T##String?#>,
//                                                                 placeholder: "Edit your name")
//                               ),
//                    SettingItem(title: "Email", icon: nil, destination: nil),
//                    SettingItem(title: "Password", icon: nil, destination: nil)
//                ]
//            case .security:
//                return nil
//            case .currency:
//                return nil
//            case .goal:
//                return nil
//            case .sources:
//                return nil
//            case .appearance:
//                return nil
//            case .notifications:
//                return nil
//            case .help:
//                return nil
//            case .rateApp:
//                return nil
//            case .logOut:
//                return nil
//        }
//    }
}

