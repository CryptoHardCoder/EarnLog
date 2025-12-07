//
//  UIView + Ext.swift
//  JobData
//
//  Created by M3 pro on 13/07/2025.
//

import UIKit

extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        
        return nil
    }
    
}


extension UIView {
        /// Slide-in снизу с fade-in
    func animateSlideInFromBottom(duration: TimeInterval = 1.0,
                                  delay: TimeInterval = 0,
                                  usingSpring: Bool = true,
                                  completion: ((Bool) -> Void)? = nil) {
            // Сохраняем изначальное состояние
        self.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
        self.alpha = 0.0

        if usingSpring {
            UIView.animate(withDuration: duration,
                           delay: delay,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseOut],
                           animations: {
                self.transform = .identity
                self.alpha = 1
            }, completion: completion)
        } else {
            UIView.animate(withDuration: duration,
                           delay: delay,
                           options: [.curveEaseOut],
                           animations: {
                self.transform = .identity
                self.alpha = 1
            }, completion: completion)
        }
    }

    func animateSlideInFromRight(translationX: CGFloat,
                                 duration: TimeInterval = 1.0,
                                 delay: TimeInterval = 0,
                                 options: UIView.AnimationOptions = [.curveEaseInOut],
                                 usingSpring: Bool = true,
                                 completion: ((Bool) -> Void)? = nil) {
        self.transform = CGAffineTransform(translationX: translationX, y: 0)
        self.alpha = 0

        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            self.transform = .identity
            self.alpha = 1
        }, completion: completion)
    }
}
