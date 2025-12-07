//
//  PasswordValidationView.swift
//  EarnLog
//
//  Created by M3 pro on 15/11/2025.
//
import UIKit

final class PasswordValidationView: UIView {

    private let lengthLabel = UILabel()
    private let uppercaseLabel = UILabel()
    private let digitLabel = UILabel()
    private let specialLabel = UILabel()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

            // Configure labels
        [lengthLabel, uppercaseLabel, digitLabel, specialLabel].forEach { label in
            label.font = .systemFont(ofSize: 14)
            label.numberOfLines = 0
        }

        stackView.addArrangedSubview(lengthLabel)
        stackView.addArrangedSubview(uppercaseLabel)
        stackView.addArrangedSubview(digitLabel)
        stackView.addArrangedSubview(specialLabel)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

            // Set initial state
        update(with: PasswordValidationState())
    }

    func update(with state: PasswordValidationState) {
        UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve) {
            self.lengthLabel.attributedText = self.createValidationText(
                isValid: state.hasMinLength,
                text: "Минимум 8 символов"
            )

            self.uppercaseLabel.attributedText = self.createValidationText(
                isValid: state.hasUppercase,
                text: "Заглавная буква"
            )

            self.digitLabel.attributedText = self.createValidationText(
                isValid: state.hasDigit,
                text: "Цифра"
            )

            self.specialLabel.attributedText = self.createValidationText(
                isValid: state.hasSpecialSymbol,
                text: "Спецсимвол (!@#$%^&*.,:/)"
            )
        }
    }

    private func createValidationText(isValid: Bool, text: String) -> NSAttributedString {
        let icon = isValid ? "✅" : "⭕️"
        let color: UIColor = isValid ? DSColors.success : DSColors.appTextSecondary

        let attributedString = NSMutableAttributedString(string: "\(icon) \(text)")
        attributedString.addAttribute(
            .foregroundColor,
            value: color,
            range: NSRange(location: 0, length: attributedString.length)
        )

        return attributedString
    }
}
