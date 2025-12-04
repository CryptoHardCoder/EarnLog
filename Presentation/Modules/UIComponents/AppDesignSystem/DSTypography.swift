//
//  DSTypography.swift
//  EarnLog
//
//  Created by M3 pro on 17/11/2025.
//
import UIKit

enum DSTypography {

        // MARK: - Headings
    case heading1(weight: UIFont.Weight = DSFontTokens.Weight.bold)
    case heading2(weight: UIFont.Weight = DSFontTokens.Weight.semibold)
    case heading3(weight: UIFont.Weight = DSFontTokens.Weight.semibold)

        // MARK: - Body Text
    case bodyLarge(weight: UIFont.Weight = DSFontTokens.Weight.regular)
    case bodyRegular(weight: UIFont.Weight = DSFontTokens.Weight.regular)
    case bodySmall(weight: UIFont.Weight = DSFontTokens.Weight.regular)

        // MARK: - Interactive Elements
    case buttonLarge(weight: UIFont.Weight = DSFontTokens.Weight.semibold)
    case buttonMedium(weight: UIFont.Weight = DSFontTokens.Weight.semibold)
    case buttonSmall(weight: UIFont.Weight = DSFontTokens.Weight.semibold)

    case textFieldInput(weight: UIFont.Weight = DSFontTokens.Weight.regular)
    case textFieldLabel(weight: UIFont.Weight = DSFontTokens.Weight.medium)
    case textFieldPlaceholder(weight: UIFont.Weight = DSFontTokens.Weight.regular)
    case textFieldError(weight: UIFont.Weight = DSFontTokens.Weight.regular)

    case tabBarItem(weight: UIFont.Weight = DSFontTokens.Weight.medium)
    case navigationTitle(weight: UIFont.Weight = DSFontTokens.Weight.semibold)

        // MARK: - Special Cases
    case caption(weight: UIFont.Weight = DSFontTokens.Weight.regular)
    case overline(weight: UIFont.Weight = DSFontTokens.Weight.semibold)
    case label(weight: UIFont.Weight = DSFontTokens.Weight.medium)

        // MARK: - Font

    var font: UIFont {
        let size: CGFloat
        let weight: UIFont.Weight

        switch self {
                    // Headings
            case .heading1(let w):
                size = DSFontTokens.Size.size28
                weight = w
            case .heading2(let w):
                size = DSFontTokens.Size.size22
                weight = w
            case .heading3(let w):
                size = DSFontTokens.Size.size18
                weight = w

                    // Body
            case .bodyLarge(let w):
                size = DSFontTokens.Size.size17
                weight = w
            case .bodyRegular(let w):
                size = DSFontTokens.Size.size15
                weight = w
            case .bodySmall(let w):
                size = DSFontTokens.Size.size13
                weight = w

                    // Buttons
            case .buttonLarge(let w):
                size = DSFontTokens.Size.size18
                weight = w
            case .buttonMedium(let w):
                size = DSFontTokens.Size.size16
                weight = w
            case .buttonSmall(let w):
                size = DSFontTokens.Size.size14
                weight = w

                    // TextFields
            case .textFieldInput(let w):
                size = DSFontTokens.Size.size16
                weight = w
            case .textFieldLabel(let w):
                size = DSFontTokens.Size.size13
                weight = w
            case .textFieldPlaceholder(let w):
                size = DSFontTokens.Size.size18
                weight = w
            case .textFieldError(let w):
                size = DSFontTokens.Size.size12
                weight = w

                    // Navigation
            case .tabBarItem(let w):
                size = DSFontTokens.Size.size10
                weight = w
            case .navigationTitle(let w):
                size = DSFontTokens.Size.size17
                weight = w

                    // Special
            case .caption(let w):
                size = DSFontTokens.Size.size12
                weight = w
            case .overline(let w):
                size = DSFontTokens.Size.size11
                weight = w
            case .label(let w):
                size = DSFontTokens.Size.size12
                weight = w
        }

        return .systemFont(ofSize: size, weight: weight)
    }


}

    // MARK: - UILabel Extension

extension UILabel {
    func applyTypography(_ typography: DSTypography, color: UIColor? = nil) {
        font = typography.font

        if let color = color {
            textColor = color
        }
    }
}

    // MARK: - UITextField Extension

extension UITextField {
    func applyTypography(_ typography: DSTypography) {
        font = typography.font
    }
}

    // MARK: - UIButton Extension

extension UIButton {
    func applyTypography(_ typography: DSTypography) {
        titleLabel?.font = typography.font
    }
}

    // MARK: - Usage Examples

/*
 // ==========================================
 // 1. ТОКЕНЫ (не используются напрямую)
 // ==========================================

 // ❌ Плохо - не используй токены напрямую
 label.font = .systemFont(ofSize: DSFontTokens.Size.size16, weight: DSFontTokens.Weight.semibold)

 // ==========================================
 // 2. ТИПОГРАФИКА (используется везде)
 // ==========================================

 // ✅ Хорошо - используй семантические стили

 // Заголовки
 let mainTitle = UILabel()
 mainTitle.apply(typography: .heading1(), color: .label)
 mainTitle.text = "Главный заголовок"

 let sectionTitle = UILabel()
 sectionTitle.apply(typography: .heading2(weight: .medium))
 sectionTitle.text = "Секция"

 // Body текст
 let descriptionLabel = UILabel()
 descriptionLabel.numberOfLines = 0
 descriptionLabel.apply(typography: .bodyRegular())
 descriptionLabel.text = "Длинное описание с правильными межстрочными интервалами"

 let subtextLabel = UILabel()
 subtextLabel.apply(typography: .bodySmall(), color: .secondaryLabel)
 subtextLabel.text = "Дополнительная информация"

 // Кнопки
 let primaryButton = DSButton(
 style: .primary,
 size: .large,
 typography: .buttonLarge()
 )

 let secondaryButton = DSButton(
 style: .secondary,
 typography: .buttonMedium(weight: .bold)
 )

 // TextField
 let emailField = UITextField()
 emailField.apply(typography: .textFieldInput())
 emailField.placeholder = "Email"

 let fieldLabel = UILabel()
 fieldLabel.apply(typography: .textFieldLabel(), color: .secondaryLabel)
 fieldLabel.text = "EMAIL ADDRESS"

 let errorLabel = UILabel()
 errorLabel.apply(typography: .textFieldError(), color: .systemRed)
 errorLabel.text = "Неверный формат email"

 // Special cases
 let timestampLabel = UILabel()
 timestampLabel.apply(typography: .caption(), color: .tertiaryLabel)
 timestampLabel.text = "2 минуты назад"

 let categoryLabel = UILabel()
 categoryLabel.apply(typography: .overline(), color: .secondaryLabel)
 categoryLabel.text = "КАТЕГОРИЯ"

 let badgeLabel = UILabel()
 badgeLabel.apply(typography: .label())
 badgeLabel.text = "NEW"

 // ==========================================
 // 3. КАСТОМИЗАЦИЯ WEIGHT
 // ==========================================

 // Легкий заголовок
 heroTitle.apply(typography: .heading1(weight: .heavy))

 // Жирный body текст для акцента
 importantText.apply(typography: .bodyRegular(weight: .semibold))

 // Тонкий подзаголовок
 subtitle.apply(typography: .heading2(weight: .regular))
 */
