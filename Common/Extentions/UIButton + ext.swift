//
//  UIButton + ext.swift
//  JobData
//
//  Created by M3 pro on 13/07/2025.
//

import UIKit

extension UIButton {
    
    func projectAnimationForButtons() {
        addTarget(self, action: #selector(buttonTappedDown), for: .touchDown)
        addTarget(self, action: #selector(buttonTappedUpInside), for: [.touchUpInside, .touchCancel, .touchUpOutside])
    }
    
    @objc
    private func buttonTappedDown() {
        UIView.animate(withDuration: 0.01, delay: 0, options: .curveEaseInOut) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.alpha = 0.8
        }
    }
    
    @objc
    private func buttonTappedUpInside() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.transform = CGAffineTransform.identity
            self.alpha = 1
        }
    }

    static func createEyeButtonForTextField(for textField: UITextField) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        button.tintColor = DSColors.appTextTertiary
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 40)

        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        config.baseBackgroundColor = .clear
        button.configuration = config

        let action = UIAction { [weak textField, weak button] _ in
            guard let textField = textField, let button = button else { return }
            textField.isSecureTextEntry.toggle()
            button.isSelected = !textField.isSecureTextEntry

                // Preserve cursor position when toggling
            if let existingText = textField.text, !existingText.isEmpty {
                textField.text = ""
                textField.text = existingText
            }
        }

            // Store textField reference using tag or closure
        button.addAction(action, for: .touchUpInside)

        return button
    }
}

extension UIButton {
    func createProjectBaseButton(title: String){
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        self.setTitleColor(DSColors.white, for: .normal)
        self.backgroundColor = DSColors.appPrimary
        self.layer.cornerRadius = 10
        self.projectAnimationForButtons()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
