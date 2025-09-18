//
//  IcloudSettingViewController.swift
//  EarnLog
//
//  Created by M3 pro on 12/08/2025.
//
import UIKit

final class IcloudSettingViewController: UIViewController, MemoryTrackable{
    let closeButton = UIButton(type: .close)
    let switchButton = UISwitch()
    let labelForSwitchButton = UILabel()
    let descriptionLabel = UILabel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        trackCreation()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        trackDeallocation() // для анализа на memory leaks
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.title = "icloud_synch_full".localized
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium)
            
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        
        labelForSwitchButton.text = "icloud_synch".localized
        labelForSwitchButton.font = .systemFont(ofSize: 18, weight: .semibold)
        
        descriptionLabel.text = "icloud_synch_description".localized
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .systemGray 
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        switchButton.addTarget(self, action: #selector(icloudSynch), for: .valueChanged)
        
        [descriptionLabel, switchButton, labelForSwitchButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)}

        NSLayoutConstraint.activate([
            
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            labelForSwitchButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            labelForSwitchButton.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            
            switchButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            switchButton.centerYAnchor.constraint(equalTo: labelForSwitchButton.centerYAnchor),
            switchButton.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor)
            
        ]) 
        
    }
    
    @objc private func closeModal() {
        dismiss(animated: true)
    }
    
    @objc func icloudSynch(){
//        let navController = UINavigationController(rootViewController: ArchiveTestViewController())
//        present(navController, animated: true)
    }

}
        

