//
//  Untitled.swift
//  EarnLog
//
//  Created by M3 pro on 05/11/2025.
//
import Foundation
import Combine

protocol AccountSettingsViewModelProtocol {
    var settingItemsPublisher: AnyPublisher<[SettingItem], Never> { get }
    var userInfoPublisher: AnyPublisher<UserProfile?, Never> { get }
    func editName(newName: String)
}
