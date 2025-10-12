


////
//  SettingsViewController.swift
//  EarnLog
//
//  Created by M3 pro on 29/07/2025.
//

import UIKit

final class SettingsViewController: UIViewController, MemoryTrackable{
    
    private let viewModel = SettingsViewModel()
    
    private let titleLabel = UILabel()
    
    private let icloudSynchButton = UIButton()
    
    private let stackViewButtons = UIStackView()
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
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
//        print(viewModel.settings)
        
        setupUI()
        setupContstraints()
    }
    
    private func setupUI(){
        view.backgroundColor = .systemBackground
        titleLabel.text = "settings".localized
        titleLabel.font = .systemFont(ofSize: 25, weight: .semibold)
        navigationItem.titleView = titleLabel
        
        let borderColor = UIColor.systemGray.withAlphaComponent(0.2)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 10
        tableView.layer.borderColor = borderColor.cgColor
        tableView.layer.borderWidth = 1
        tableView.backgroundColor = .systemBackground
//        tableView.separatorStyle = .none
        tableView.separatorColor = borderColor
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 40
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
//        let icon = UIImage(systemName: "icloud")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
//        
//        icloudSynchButton.setTitle("icloud_synch".localized, for: .normal)
//        icloudSynchButton.setTitleColor(.label, for: .normal)
//        icloudSynchButton.setImage( icon ,for: .normal)
//        icloudSynchButton.setImage( icon ,for: .highlighted)
//        
////        icloudSynchButton.imageView?.tintColor = 
//        icloudSynchButton.setTitleColor(
//                .systemGray.withAlphaComponent(0.5),
//                for: .highlighted)
//        icloudSynchButton.addTarget(self, action: #selector(iCloudButtonAction), for: .touchUpInside)
//        icloudSynchButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        stackViewButtons.translatesAutoresizingMaskIntoConstraints = false
//        stackViewButtons.addArrangedSubview(icloudSynchButton)
//        stackViewButtons.alignment = .leading
//        stackViewButtons.spacing = 5
//        stackViewButtons.axis = .vertical
//        stackViewButtons.tintColor = .black
//        stackViewButtons.layer.borderColor = UIColor.systemGray.cgColor
//        stackViewButtons.layer.borderWidth = 1
//        stackViewButtons.layer.cornerRadius = 7
//        stackViewButtons.isLayoutMarginsRelativeArrangement = true // если нужны отступы
//        
//        
        view.addSubview(tableView)
    }
    
    private func setupContstraints(){
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor) // 🔹 добавлено
            tableView.heightAnchor.constraint(equalToConstant: 400)
        ])
//        NSLayoutConstraint.activate([
//            
//            
//            stackViewButtons.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 40),
//            stackViewButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            stackViewButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//        ])
    }

    
    
}

extension SettingsViewController: UITableViewDelegate{
}

extension SettingsViewController: UITableViewDataSource{
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.settings.count
//        switch section{
//            case 0:
//                return self.viewModel.settings.count
//            case 1:
//                return 4
//            case 2:
//                return 5
//            default:
//                return 0
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let setting = self.viewModel.settings[indexPath.row]
        var content = cell.defaultContentConfiguration()
        
        content.text = setting.title
        switch setting{
            case .iCloudSetting: 
                content.image = UIImage(systemName: "icloud") 
            case .sourceSetting:
                content.image = UIImage(systemName: "note.text.badge.plus")
            case .archiveSetting:
                content.image = UIImage(systemName: "books.vertical")
            case .deletePreviousMonthItems:
                content.image = UIImage(systemName: "trash")
                
        }
        
//        switch indexPath.section{
//            case 0:
//                let setting = self.viewModel.settings[indexPath.row]
//                content.text = setting.description
//                switch setting{
//                    case .iCloudSetting: 
//                        content.image = UIImage(systemName: "icloud") 
//                    case .sourceSetting:
//                        content.image = UIImage(systemName: "note.text.badge.plus")
//                }
//            case 1:
//                content.text = "Будущие настройки"
//                content.image = UIImage(systemName: "questionmark")
//            case 2:
//                content.text = "Будущие настройки"
//                content.image = UIImage(systemName: "questionmark")
//            default:
//                   content.text = ""
//        }
        if content.image == UIImage(systemName: "trash"){
            content.imageProperties.tintColor = UIColor.systemRed
        } else {
            content.imageProperties.tintColor = .systemBlue
        }
        
        content.imageProperties.reservedLayoutSize = CGSize(width: 24, height: 24)
    
        cell.contentConfiguration = content
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator 
        cell.backgroundColor = .systemBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let setting = viewModel.settings[indexPath.row]
        let vc = self.viewModel.makeViewController(for: setting)
        navigationController?.pushViewController(vc, animated: true)
    }
    


}


