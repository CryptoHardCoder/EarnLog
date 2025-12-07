//
//  AvatarSelectionViewController.swift
//  EarnLog
//
//  Created by M3 pro on 02/11/2025.
//
import UIKit

protocol AvatarSelectionDelegate: AnyObject {
    func didSelectChoosePhoto()
    func didSelectTakePhoto()
}

class AvatarSelectionView: UIViewController {
    
    weak var delegate: AvatarSelectionDelegate?
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColors.appBackground
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(stackView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Change Avatar"
        titleLabel.textColor = DSColors.appTextPrimary
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        
        let chooseButton = createButton(title: "Choose Photo", action: #selector(choosePhotoTapped))
        let takeButton = createButton(title: "Take Photo", action: #selector(takePhotoTapped))
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(chooseButton)
        stackView.addArrangedSubview(takeButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
        ])
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(DSColors.appPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = DSColors.gray.cgColor
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
    
    @objc private func choosePhotoTapped() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelectChoosePhoto()
        }
    }
    
    @objc private func takePhotoTapped() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelectTakePhoto()
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}
