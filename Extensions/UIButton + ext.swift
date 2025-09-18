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
        addTarget(self, action: #selector(buttonTappedUpInside), for: .touchUpInside)
    }
    
    @objc func buttonTappedDown() {
        UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseInOut) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.alpha = 0.8
        }
    }
    
    @objc func buttonTappedUpInside() {
        UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseInOut) {
            self.transform = CGAffineTransform.identity
            self.alpha = 1
        }
    }
}

