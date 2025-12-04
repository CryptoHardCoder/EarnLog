//
//  DSButton.swift
//  EarnLog
//
//  Created by M3 pro on 17/11/2025.
//
import UIKit


final class DSButton: UIButton {

        // MARK: - Helper Structures
    private struct StyleConfig {
        let backgroundColor: UIColor
        let textColor: UIColor
        let borderColor: UIColor?
        let borderWidth: CGFloat
    }

        // MARK: - Properties
    private let style: DSButtonStyle
    private let size: DSButtonSize
    private let cornerRadius: DSRadiuses
    private let font: DSTypography

        // MARK: - Initialization
    init(style: DSButtonStyle, size: DSButtonSize = .medium, cornerRadius: DSRadiuses = .medium, font: DSTypography = .buttonMedium(weight: .medium)) {
        self.style = style
        self.size = size
        self.cornerRadius = cornerRadius
        self.font = font
        super.init(frame: .zero)
        setupUI()
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

        // MARK: - Setup

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

            // Скругление углов
        layer.cornerRadius = cornerRadius.radius
        clipsToBounds = true

            // Constraints для высоты
        heightAnchor.constraint(equalToConstant: size.height).isActive = true

            // Анимация при нажатии
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
    }

        // MARK: - Configuration

    func configure(title: String, icon: UIImage? = nil) {
        setTitle(title, for: .normal)
        titleLabel?.font = font.font

        if let icon = icon {
            let resizedIcon = icon.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: size.iconSize, weight: .semibold)
            )
            setImage(resizedIcon, for: .normal)
        } else {
            setImage(nil, for: .normal)
        }

        updateAppearance()
    }

        // MARK: - Styling

    private func updateAppearance() {
        let config = getStyleConfig()

        backgroundColor = config.backgroundColor
        setTitleColor(config.textColor, for: .normal)
        tintColor = config.textColor // Для иконок

        layer.borderWidth = config.borderWidth
        layer.borderColor = config.borderColor?.cgColor

        alpha = isEnabled ? 1.0 : 0.5
    }

    private func getStyleConfig() -> StyleConfig {
        switch style {
            case .default:
                return StyleConfig(
                    backgroundColor: .clear,
                    textColor: DSColors.appPrimary,
                    borderColor: DSColors.gray,
                    borderWidth: 1)
            case .primary:
                return StyleConfig(
                    backgroundColor: DSColors.ButtonColors.primaryButtonColor,
                    textColor: DSColors.white,
                    borderColor: nil,
                    borderWidth: 0
                )

            case .secondary:
                return StyleConfig(
                    backgroundColor: .clear,
                    textColor: DSColors.appPrimary,
                    borderColor: DSColors.appPrimary,
                    borderWidth: 1
                )

            case .destructive:
                return StyleConfig(
                    backgroundColor: .clear,
                    textColor: DSColors.error,
                    borderColor: DSColors.error,
                    borderWidth: 1
                )
        }
    }

        // MARK: - State Handling

    override var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }

    @objc private func touchDown() {
        UIView.animate(withDuration: 0.01, delay: 0, options: .curveEaseOut) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.alpha = 0.8
        }
    }

    @objc private func touchUp() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
            self.transform = .identity
            self.alpha = self.isEnabled ? 1.0 : 0.8
        }
    }

}

    // MARK: - Convenience Factory Methods

extension DSButton {

    static func `default`(
        _ title: String,
        icon: UIImage? = nil,
        size: DSButtonSize = .medium,
        corner: DSRadiuses = .medium,
        font: DSTypography = .buttonMedium(weight: .medium)
    ) -> DSButton{
        let button = DSButton(style: .default, size: size, cornerRadius: corner, font: font)
        button.configure(title: title, icon: icon)
        return button
    }

    static func primary(
        _ title: String,
        icon: UIImage? = nil,
        size: DSButtonSize = .medium,
        corner: DSRadiuses = .medium,
        font: DSTypography = .buttonMedium(weight: .medium)
    ) -> DSButton {
        let button = DSButton(style: .primary, size: size, cornerRadius: corner, font: font)
        button.configure(title: title, icon: icon)
        return button
    }

    static func secondary(
        _ title: String,
        icon: UIImage? = nil,
        size: DSButtonSize = .medium,
        corner: DSRadiuses = .medium,
        font: DSTypography = .buttonMedium(weight: .medium)
    ) -> DSButton {
        let button = DSButton(style: .secondary, size: size, cornerRadius: corner, font: font)
        button.configure(title: title, icon: icon)
        return button
    }

    static func destructive(
        _ title: String,
        icon: UIImage? = nil,
        size: DSButtonSize = .medium,
        corner: DSRadiuses = .medium,
        font: DSTypography = .buttonMedium(weight: .medium)
    ) -> DSButton {
        let button = DSButton(style: .destructive, size: size, cornerRadius: corner, font: font)
        button.configure(title: title, icon: icon)
        return button
    }
}
