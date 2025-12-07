//
//  UIView + ext.swift
//  JobData
//
//  Created by M3 pro on 13/07/2025.
//

import UIKit

extension UIViewController {
    
    func dismissActiveKeyboard(){
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

}

extension UIViewController: @retroactive UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            // Не закрываем клавиатуру если тап по интерактивным элементам
        if touch.view is UIButton ||
            touch.view is UITextField ||
            touch.view is UITextView ||
            touch.view is UISwitch ||
            touch.view is UISlider {
            return false
        }
//
//            // Проверяем rightView текстовых полей (для кнопок-глазиков и т.д.)
//        if let textField = findTextFieldWithRightView(containing: touch) {
//            return false
//        }

        return true
    }
}
