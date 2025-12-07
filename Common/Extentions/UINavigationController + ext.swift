//
//  UINavigationController + ext.swift
//  EarnLog
//
//  Created by M3 pro on 26/11/2025.
//
import UIKit

extension UINavigationController {
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        appearance.shadowColor = .clear
        appearance.shadowImage = nil

        appearance.titleTextAttributes = [
            .foregroundColor: DSColors.appTextPrimary,
        ]

        appearance.largeTitleTextAttributes = [
            .foregroundColor: DSColors.appTextPrimary,
        ]

        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance

        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }

        navigationBar.prefersLargeTitles = true
        navigationBar.isTranslucent = true
        navigationBar.tintColor = DSColors.appPrimary

        navigationBar.backgroundColor = .clear
    }
}
