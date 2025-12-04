//
//  CustomAlert.swift
//  EarnLog
//
//  Created by M3 pro on 23/10/2025.
//

import Foundation
import UIKit

final class CustomAlert {
    private let title: String
    private var message: String?
    private var animationFile: LottieAnimationFiles?
    private var textFieldText: String?
    private var actions: [AlertAction] = []

    private var textFieldInputHandler: ((String) -> Void)?

    init(title: String) {
        self.title = title
    }

    @discardableResult
    func withLottieAnimation(_ file: LottieAnimationFiles) -> Self {
        self.animationFile = file
        return self
    }
    
    @discardableResult
    func withTextField(initialText: String = "", onInput: @escaping (String) -> Void) -> Self {
        self.textFieldText = initialText
        self.textFieldInputHandler = onInput
        return self
    }

    @discardableResult
    func addAction(_ action: AlertAction) -> Self {
        actions.append(action)
        return self
    }

    func showAlert(from viewController: UIViewController) {
        let alertVC = CustomAlertViewController(
            alertTitle: title,
            alertMessage: message,
            lottieAnimationFile: animationFile,
            textFieldText: textFieldText,
            actions: actions)
        alertVC.onTextFieldInput = textFieldInputHandler
        viewController.present(alertVC, animated: true)
    }
}

extension CustomAlert {

    convenience init(title: String, message: String){
        self.init(title: title)
        self.message = message
    }

    convenience init(title: String, message: String, animationFile: LottieAnimationFiles) {
        self.init(title: title)
        self.message = message
        self.animationFile = animationFile
        self.textFieldText = nil
    }
}

extension CustomAlert{
    static func alertWithSingleButton(title: String,
                                      message: String,
                                      buttonTitle: String,
                                      handler: (() -> Void)?) -> CustomAlert {
        let alert = CustomAlert(title: title, message: message)
        let action = AlertAction(title: buttonTitle, style: .baseDefault, handler: handler)
        return alert.addAction(action)
    }
}
