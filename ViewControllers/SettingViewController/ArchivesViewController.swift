//
//  ArchivesViewController.swift
//  EarnLog
//
//  Created by M3 pro on 15/08/2025.
//

import Foundation
import UIKit

final class ArchivesViewController: UIViewController, MemoryTrackable{
    
    private let viewModel = ArchivesViewModel()
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let descriptionLabel = UILabel()
    
    private let noneArchives = UILabel()
    
    private var withTableView: [NSLayoutConstraint] = []
    private var withNoneArchives: [NSLayoutConstraint] = []
    
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
//        print(SideJobStorage.shared.loadAllCustomJobs())
        
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "archive_data".localized
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium)
            
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        descriptionLabel.text = "archive_data_description".localized
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .systemGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        
        noneArchives.text = "not_fined_archives".localized
        noneArchives.font = .systemFont(ofSize: 20, weight: .medium)
        noneArchives.textColor = .label
        noneArchives.numberOfLines = 0
        noneArchives.lineBreakMode = .byWordWrapping
        noneArchives.textAlignment = .center
        noneArchives.translatesAutoresizingMaskIntoConstraints = false
        noneArchives.isHidden = true
        
        view.addSubview(descriptionLabel)
        view.addSubview(tableView)
        view.addSubview(noneArchives)
        
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Обновляем данные
//        viewModel.refreshData()
        tableView.reloadData()
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        withTableView = [
            tableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ]
        
        withNoneArchives = [
            noneArchives.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
//            noneArchives.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noneArchives.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noneArchives.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            noneArchives.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ]
    }
    
    
}

extension ArchivesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.archiveFiles.count
        

        if count == 0 {
            // Можно добавить empty state view
//            print("📭 Нет доступных архивов") 
            noneArchives.isHidden = false
            NSLayoutConstraint.activate(withNoneArchives)
        } else {
            tableView.isHidden = false
            NSLayoutConstraint.activate(withTableView)
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let cellData = viewModel.getDataForCell()
        
        guard indexPath.row < cellData.count else {
            print("ArchivesViewController.tableView.cellForRowAt: ❌ Индекс вне границ массива данных")
            return cell
        }
        
        let (_, metadata) = cellData[indexPath.row]
        
        var content = cell.defaultContentConfiguration()

        content.text = "\("data_for".localized) \(metadata.monthDisplayName(Locale(identifier: "locale".localized)))"       
        content.textProperties.alignment = .justified
        content.textProperties.color = .label
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellData = viewModel.getDataForCell()
        
        guard indexPath.row < cellData.count else {
            print("❌ Индекс вне границ при выборе ячейки")
            return
        }
        
        let (_, metadata) = cellData[indexPath.row]
        
        let year = metadata.year
        let month = metadata.month
//        print(month)
        
        let archiveController = ArchiveReviewController(year: year, month: month, metaData: metadata)
        let navController = UINavigationController(rootViewController: archiveController)
        
        present(navController, animated: true)
    }
}
