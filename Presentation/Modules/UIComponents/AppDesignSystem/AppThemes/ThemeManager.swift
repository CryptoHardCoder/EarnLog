//
//  ThemeManager.swift
//  EarnLog
//
//  Created by M3 pro on 22/11/2025.
//

import UIKit

final class ThemeManager {
    
    static let shared = ThemeManager()

    private lazy var defaultTheme: AppTheme = .light

    private(set) lazy var userTheme: AppTheme = defaultTheme

    private let userThemeKey = "appUserTheme"

    private init(){
        loadSavedTheme()
    }

    func apply(theme: AppTheme) {

        guard let scene = UIApplication.shared
            .connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }

        guard let window = scene.windows.first else { return }

        animateThemeChange(on: window) {
            scene.traitOverrides.appTheme = theme
        }

        userTheme = theme

        saveUserTheme()
    }

    private func saveUserTheme(){
        UserDefaults.standard.setValue(userTheme.rawValue, forKey: userThemeKey)
    }

    @discardableResult
    func loadSavedTheme() -> AppTheme {
        if let themeRawValue = UserDefaults.standard.value(forKey: userThemeKey) as? Int,
            let savedTheme = AppTheme(rawValue: themeRawValue) {
            userTheme = savedTheme
            return savedTheme
//            print("\(userTheme.name)")
        }
        return defaultTheme
    }

    private func animateThemeChange(on window: UIWindow, changes: () -> Void) {
        let snapshot = window.snapshotView(afterScreenUpdates: false)!
        window.addSubview(snapshot)

        changes()

        UIView.animate(withDuration: 0.35, animations: {
            snapshot.alpha = 0
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
    }

}
