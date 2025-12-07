//
//  SectionBackgroundView.swift
//  EarnLog
//
//  Created by M3 pro on 01/11/2025.
//
import UIKit


final class SectionBackgroundView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(){
        backgroundColor = DSColors.appBackground
        layer.shadowColor = DSColors.shadowColor.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 0)
        if #available(iOS 26.0, *) {
            cornerConfiguration = .corners(radius: 20)
        } else {
            layer.cornerRadius = 12
        }
    }
}
