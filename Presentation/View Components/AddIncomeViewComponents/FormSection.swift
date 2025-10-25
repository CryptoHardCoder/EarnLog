//
//  FormSection.swift
//  EarnLog
//
//  Created by M3 pro on 18/10/2025.
//
import UIKit

// MARK: - FormSection
final class FormSection: UIView {
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 5
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    init(title: String, subtitle: String? = nil, textField: UITextField) {
        super.init(frame: .zero)
        
        let titleLabel = createLabel(text: title, isSubtitle: false)
        let headerStack = UIStackView(arrangedSubviews: [titleLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        
        if let subtitle {
            let subtitleLabel = createLabel(text: subtitle, isSubtitle: true)
            headerStack.addArrangedSubview(subtitleLabel)
        }
        
        stackView.addArrangedSubview(headerStack)
        stackView.addArrangedSubview(textField)
        
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createLabel(text: String, isSubtitle: Bool) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = isSubtitle ? .black200 : .designBlack
        label.font = isSubtitle ? .italicSystemFont(ofSize: 20) : .systemFont(ofSize: 20, weight: .semibold)
        return label
    }
}
