//
//  Settings.swift
//  EarnLog
//
//  Created by M3 pro on 12/08/2025.
//

import Foundation

enum Settings: CaseIterable{
    case iCloudSetting
    case sourceSetting
    case archiveSetting
    case deletePreviousMonthItems
    
    
    
    var title: String {
        switch self {
            case .iCloudSetting: 
                return "icloud_synch".localized
            case .sourceSetting:
                return "edit_part_time_jobs".localized
            case .archiveSetting:
                return "archive_data".localized
            case .deletePreviousMonthItems:
                return "delete_old_items".localized
        }
    }
    
    
}
