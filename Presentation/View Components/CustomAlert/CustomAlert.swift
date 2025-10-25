//
//  CustomAlert.swift
//  EarnLog
//
//  Created by M3 pro on 23/10/2025.
//

import Foundation
import UIKit

final class CustomAlert{
    private let title: String
    private let message: String
    private var animationFile: LottieAnimationFiles?
    private var actions: [AlertAction] = []

    init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    @discardableResult
    func setLottieAnimationFile(_ file: LottieAnimationFiles) -> Self {
        self.animationFile = file
        return self
    }

    @discardableResult
    func addAction(_ action: AlertAction) -> Self {
        actions.append(action)
        return self
    }

    func showAlert(from viewController: UIViewController) {
        let alerVC = CustomAlertViewController(
            alertTitle: title,
            alertMessage: message,
            lottieAnimationFile: animationFile,
            actions: actions)
        viewController.present(alerVC, animated: true)
    }
}

extension CustomAlert {
    convenience init(title: String, message: String, animationFile: LottieAnimationFiles?) {
        self.init(title: title, message: message)
        self.animationFile = animationFile
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
