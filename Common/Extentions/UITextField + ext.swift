//
//  UITextField + ext.swift
//  EarnLog
//
//  Created by M3 pro on 29/10/2025.
//
import UIKit
import Combine

extension UITextField{

    static func makePasswordField(placeholder: String, textContentType: UITextContentType = .password ) -> UITextField {
        let textField = UITextField.makeBaseTextField(placeholder: placeholder)
        textField.isSecureTextEntry = true
        textField.textContentType = .password
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.accessibilityLabel = placeholder

        let eyeButton = UIButton.createEyeButtonForTextField(for: textField)
        textField.rightView = eyeButton
        textField.rightViewMode = .always

        return textField
    }

    static func makeBaseTextField(placeholder: String? = nil, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .sentences
        textField.returnKeyType = .done
        textField.font = DSTypography.textFieldPlaceholder(weight: .semibold).font
        textField.textColor = DSColors.appTextPrimary
        textField.layer.borderColor = DSColors.gray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = DSRadiuses.medium.radius
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        guard let placeholder else { return textField }
        textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                        attributes: [.foregroundColor: DSColors.gray])
        return textField
    }


}

    // MARK: - Publisher Extension

extension UITextField {
    func publisher(for keyPath: KeyPath<UITextField, String?>) -> AnyPublisher<String?, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }
}
