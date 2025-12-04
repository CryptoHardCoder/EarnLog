//
//  UITraitCollection + ext.swift
//  EarnLog
//
//  Created by M3 pro on 22/11/2025.
//
import UIKit

extension UITraitCollection {
    var appTheme: AppTheme { self[AppThemeTrait.self] }
}
