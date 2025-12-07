//
//  ChangeAppearanceViewModel.swift
//  EarnLog
//
//  Created by M3 pro on 23/11/2025.
//


final class ChangeAppearanceViewModel: ChangeAppearanceViewModelProtocol {

    let themes: [AppTheme] = AppTheme.allCases

    var userTheme: AppTheme {
        ThemeManager.shared.userTheme
    }
}
