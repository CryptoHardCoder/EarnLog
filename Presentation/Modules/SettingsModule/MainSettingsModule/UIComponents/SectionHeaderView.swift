//
//  SectionHeaderView.swift
//  EarnLog
//
//  Created by M3 pro on 01/11/2025.
//
import UIKit

final class SectionHeaderView: UICollectionReusableView {
    static let identifier = "SectionHeaderView"
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = DSColors.appTextTertiary
        label.textAlignment = .natural
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String) {
        label.text = text
    }
}
