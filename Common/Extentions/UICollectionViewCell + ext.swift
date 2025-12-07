//
//  UICollectionViewCell + ext.swift
//  EarnLog
//
//  Created by M3 pro on 02/11/2025.
//

import UIKit

extension UICollectionViewCell {

    func animateTouchForCell(){

        UIView.animate(withDuration: 0.05, animations: {
            self.contentView.alpha = 0.3
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.contentView.alpha = 1
            }
        }

    }
}
