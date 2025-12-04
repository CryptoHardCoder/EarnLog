//
//  UIMutableTraits + ext.swift
//  EarnLog
//
//  Created by M3 pro on 22/11/2025.
//
import UIKit

extension UIMutableTraits {
    var appTheme: AppTheme {
        get { self[AppThemeTrait.self] }
        set { self[AppThemeTrait.self] = newValue }
    }
}
