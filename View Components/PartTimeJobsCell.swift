//
//  SettingTableViewCell.swift
//  EarnLog
//
//  Created by M3 pro on 12/08/2025.
//
import UIKit

final class PartTimeJobsCell: UITableViewCell, MemoryTrackable {
    static let reuseIdentifier = "PartTimeJobsCell"
    
    private let label = UILabel()
    private let textField = UITextField()
    
    var onTextChanged: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        trackCreation()  // для анализа memory leaks
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Label
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.isHidden = false
        
        // TextField
        textField.delegate = self
        textField.borderStyle = .roundedRect
        textField.isHidden = true
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.returnKeyType = .done
        
        // Двойной тап для редактирования
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(startEditing))
        doubleTap.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTap)
        
        contentView.addSubview(label)
        contentView.addSubview(textField)
    }
    
    private func setupLayout() {
        label.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(text: String) {
//        print("configure")
        label.text = text
        textField.text = text
        textField.isHidden = true
        label.isHidden = false
    }
    
    @objc func startEditing() {
//        print("startEditing")
        textField.text = label.text
        label.isHidden = true
        textField.isHidden = false
        textField.becomeFirstResponder()
    }
    
    deinit{
        trackDeallocation() // для анализа memory leaks
    }
}

// MARK: - UITextFieldDelegate
extension PartTimeJobsCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        finishEditing()
        return true
    }

    
    private func finishEditing() {
        let newText = textField.text ?? ""
        label.text = newText
        label.isHidden = false
        textField.isHidden = true
        onTextChanged?(newText)
//        print("finishEditing")
    }
}
