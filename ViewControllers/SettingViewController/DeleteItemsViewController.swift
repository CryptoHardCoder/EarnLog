//
//  DeleteItemsViewController.swift
//  EarnLog
//
//  Created by M3 pro on 17/08/2025.
//

import Foundation
import UIKit

final class DeleteItemsViewController: UIViewController, MemoryTrackable{

    let deleteButton = UIButton()
    let chekArchiveButton = UIButton()
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
        navigationItem.title = "delete_old_items".localized
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium)
            
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        chekArchiveButton.setTitle("chek_archives".localized, for: .normal)
        chekArchiveButton.setTitleColor(UIColor.systemGreen, for: .normal)
        chekArchiveButton.setTitleColor(UIColor.systemGreen.withAlphaComponent(0.2), for: .highlighted)
        chekArchiveButton.addTarget(self, action: #selector(chekArchive), for: .touchUpInside)
        
        deleteButton.setTitle("delete_old_items".localized, for: .normal)
        deleteButton.setTitleColor(UIColor.systemRed, for: .normal)
        deleteButton.setTitleColor(UIColor.systemRed.withAlphaComponent(0.2), for: .highlighted)
        deleteButton.addTarget(self, action: #selector(deleteItems), for: .touchUpInside)
        
        
        descriptionLabel.text = "delete_old_items_description".localized
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .systemGray 
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        
        [descriptionLabel, chekArchiveButton, deleteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)}

        NSLayoutConstraint.activate([
            
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            chekArchiveButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            chekArchiveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: chekArchiveButton.bottomAnchor, constant: 40),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ]) 
        
    }
    
    @objc private func deleteItems() {
        showDeleteAlert()
        
    }
    
    @objc func chekArchive(){
        let vc = ArchivesViewController()
        present(vc, animated: true)
    }
    
    private func showDeleteAlert(){
        let alertController = UIAlertController(title: "delete_entry".localized, message: "confirm_delete".localized, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "yes".localized, style: .destructive) { _ in
            let result = AppCoreServices.shared.appFileManager.deletePreviousMonthItems()
            self.showResultAlert(result: result) 
        })
        
        alertController.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func showResultAlert(result: Bool){

        let alert = UIAlertController(title: "operation_result".localized,
                                      message: result ? "operation_success".localized : "operation_failed".localized, 
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }

}
