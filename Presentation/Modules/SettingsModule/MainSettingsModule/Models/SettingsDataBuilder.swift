//
//  SettingsDataBuilder.swift
//  EarnLog
//
//  Created by M3 pro on 26/10/2025.
//
import UIKit

final class SettingsDataBuilder {

        // Главный метод, который строит все секции настроек
    func buildMainSettings() -> [SettingsSection] {
        return [
            buildAvatarSection(),
            buildAccountSection(),
            buildPreferencesSection(),
            buildSupportSection(),
        ]
    }

    func buildAccountSettingsData() -> [SettingItem] {
        return [
            SettingItem(
                title: "Edit name",
                icon: UIImage(systemName: "person.text.rectangle"),
                destination: .account([.editName]),
                interactionType: .alert
            ),
            SettingItem(
                title: "Change email",
                icon: UIImage(systemName: "envelope"),
                destination: .account([.updateEmail]),
                interactionType: .navigation
            ),
            SettingItem(
                title: "Change password",
                icon: UIImage(systemName: "lock.open.rotation"),
                destination: .account([.updatePassword]),
                interactionType: .navigation
            )
        ]
    }

        // Приватные методы для построения каждой секции
    private func buildAvatarSection() -> SettingsSection {
        return SettingsSection(
            title: nil,
            items: [
                buildItem(
                    title: "Avatar",
                    icon: nil,
                    destination: .avatar
                )
            ]
        )
    }

    private func buildAccountSection() -> SettingsSection {
        return SettingsSection(
            title: "Account",
            items: [
                buildItem(
                    title: "Account",
                    icon: UIImage(systemName: "person"),
                    destination: .account([.editName, .updateEmail, .updatePassword])
                ),
                buildItem(
                    title: "Security",
                    icon: UIImage(systemName: "lock.shield"),
                    destination: .security([.setPIN, .setFaceID])
                ),
                buildItem(
                    title: "Goal",
                    icon: UIImage(systemName: "scope"),
                    destination: .goals
                ),
                buildItem(
                    title: "Currency",
                    icon: UIImage(systemName: "dollarsign.arrow.circlepath"),
                    destination: .currency
                ),
                buildItem(
                    title: "Income sources",
                    icon: UIImage(systemName: "briefcase"),
                    destination: .sources)
            ]
        )
    }

    private func buildPreferencesSection() -> SettingsSection {
        return SettingsSection(
            title: "Preferences",
            items: [
                buildItem(title: "Appearance",
                          icon: UIImage(systemName: "sun.lefthalf.filled"),
                          destination: .appearance([.system, .dark, .light])
                         ),
                buildItem(title: "Notifications",
                          icon: UIImage(systemName: "bell"),
                          destination: .notifications)
            ]
        )
    }

    private func buildSupportSection() -> SettingsSection {
        return SettingsSection(
            title: "Support",
            items: [
                buildItem(
                    title: "Help",
                    icon: UIImage(systemName: "info.circle"),
                    destination: .help
                ),
                buildItem(
                    title: "Rate the Application",
                    icon: UIImage(systemName: "star.circle"),
                    destination: .rateApp
                ),
                buildItem(
                    title: "Log out",
                    icon: UIImage(systemName: "rectangle.portrait.and.arrow.forward"),
                    destination: .logOut
                )

            ])
    }
        // Это ключевой метод, который определяет interactionType
    private func buildItem(title: String, icon: UIImage?, destination: SettingsDestination) -> SettingItem {
        let interactionType = determineInteractionType(for: destination)
        return SettingItem(
            title: title,
            icon: icon,
            destination: destination,
            interactionType: interactionType
        )
    }

        // Вся логика определения типа взаимодействия живет здесь
    private func determineInteractionType(for destination: SettingsDestination) -> SettingInteractionType {
        switch destination {
            case .avatar:
                return .action
            case .account(let settings):
                if settings.contains(.editName) && settings.count == 1 {
                    return .action
                }
                return .navigation
            case .logOut, .rateApp:
                return .alert

            default:
                return .navigation
        }
    }
}
//
//final class SettingsData {
//
//    static let shared = SettingsData()
//
//    let mainSettingSectionsData: [SettingsSection] = [
//
//        SettingsSection(
//            title: nil,
//            items: [
//                SettingItem(title: "Avatar", icon: nil, destination: .avatar)
//            ]
//        ),
//
//        SettingsSection(
//            title: "Account",
//            items: [
//                SettingItem(
//                    title: "Account",
//                    icon: UIImage(systemName: "person"),
//                    destination: .account([.editName, .updateEmail, .updatePassword])
//                ),
//
//                SettingItem(
//                    title: "Security",
//                    icon: UIImage(systemName: "lock.shield"),
//                    destination: .security([.setPIN, .setFaceID])
//                ),
//
//                SettingItem(title: "Currency",
//                            icon: UIImage(systemName: "dollarsign.arrow.circlepath"),
//                            destination: .currency),
//
//                SettingItem(title: "Goal",
//                            icon: UIImage(systemName: "scope"),
//                            destination: .goals),
//
//                SettingItem(title: "Income sources",
//                            icon: UIImage(systemName: "briefcase"),
//                            destination: .sources)
//            ]
//        ),
//
//        SettingsSection(
//            title: "Preferences",
//            items: [
//                SettingItem(
//                    title: "Appearance",
//                    icon: UIImage(systemName: "sun.lefthalf.filled"),
//                    destination: .appearance([.system, .dark, .light])
//                ),
//                SettingItem(
//                    title: "Notifications",
//                    icon: UIImage(systemName: "bell"),
//                    destination: .notifications
//                ),
//            ]
//        ),
//        
//        SettingsSection(
//            title: "Support",
//            items: [
//                SettingItem(
//                    title: "Help",
//                    icon: UIImage(systemName: "info.circle"),
//                    destination: .help
//                ),
//                SettingItem(
//                    title: "Rate the Application",
//                    icon: UIImage(systemName: "star.circle"),
//                    destination: .rateApp
//                ),
//                SettingItem(
//                    title: "Log out",
//                    icon: UIImage(systemName: "rectangle.portrait.and.arrow.forward"),
//                    destination: .logOut
//                ),
//            ]
//        ),
//    ]
//
//    func getAccountSettingsData(_ currentName: String) -> [SettingItem] {
//        return [
//            SettingItem(
//                title: "Edit name",
//                icon: UIImage(systemName: "person.text.rectangle"),
//                destination: .account([.editName])
//            ),
//            SettingItem(
//                title: "Change email",
//                icon: UIImage(systemName: "envelope"),
//                destination: .account([.updateEmail])
//            ),
//            SettingItem(
//                title: "Change password",
//                icon: UIImage(systemName: "lock.open.rotation"),
//                destination: .account([.updatePassword])
//            )
//        ]
//    }
//
//}
