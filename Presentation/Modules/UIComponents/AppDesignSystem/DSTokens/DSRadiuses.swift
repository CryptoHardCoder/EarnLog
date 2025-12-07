//
//  DSRadiuses.swift
//  EarnLog
//
//  Created by M3 pro on 17/11/2025.
//
import UIKit

enum DSRadiuses {
    case small
    case medium
    case large

    var radius: CGFloat {
        switch self {
            case .small:  8
            case .medium: 12
            case .large: 20
        }
    }
}
