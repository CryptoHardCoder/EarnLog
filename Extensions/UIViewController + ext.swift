//
//  UIView + ext.swift
//  JobData
//
//  Created by M3 pro on 13/07/2025.
//

import UIKit

extension UIViewController {
    
    func hideKeyboard(){
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(keyboardHidden))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardHidden() {
        view.endEditing(true)
    }

}
