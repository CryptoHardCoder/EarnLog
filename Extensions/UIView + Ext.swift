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
