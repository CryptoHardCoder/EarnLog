//
//  SettingsFactory.swift
//  EarnLog
//
//  Created by M3 pro on 18/08/2025.
//
import UIKit

final class SettingsFactory {
    func makeViewController(for setting: Settings) -> UIViewController {
        switch setting {
            case .iCloudSetting:
                return IcloudSettingViewController()
            case .sourceSetting:
                return PartTimeJobsSettingsViewController()
            case .archiveSetting:
                return ArchivesViewController()
    //                return ArchiveTestViewController()
            case .deletePreviousMonthItems:
                return DeleteItemsViewController()
        }
    }
}
