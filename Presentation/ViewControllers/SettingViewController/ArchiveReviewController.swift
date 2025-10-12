//
//  ArchiveReviewController.swift
//  EarnLog
//
//  Created by M3 pro on 15/08/2025.
//

import Foundation
import UIKit

final class ArchiveReviewController: UIViewController, MemoryTrackable {
    
    private let viewModel: ArchiveReviewViewModel
    
    private let year: Int
    private let month: Int 
    private let metaData: ArchiveMetadata
    
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let dailyAverageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalCountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let summaryLabel: UILabel = {
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 15 // 👉 между строками
//        paragraphStyle.alignment = .center
//
//        let attributes: [NSAttributedString.Key: Any] = [
//            .paragraphStyle: paragraphStyle,
//            .font: label.font as Any
//        ]
//        label.attributedText = NSAttributedString(string: "...", attributes: attributes)
        return label
    }()
    
    private let tableView = UITableView()
    
    init(year: Int, month: Int, metaData: ArchiveMetadata){
        self.year = year
        self.month = month
        self.metaData = metaData
        self.viewModel = ArchiveReviewViewModel(year: self.year, month: self.month, metaData: self.metaData)
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
        navigationItem.title = "archive_data".localized
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium)
            
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), 
                                                            style: .plain, target: self, action: #selector(exportData))
        setupUI()
        
    }
    
    private func setupUI(){
        
        getLabelTexts()
        
        [totalCountLabel, summaryLabel, dailyAverageLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(IncomeTableViewCell.self, forCellReuseIdentifier: IncomeTableViewCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(tableView)
        
        setupConstraints()
        
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    @objc func exportData(){
//        let url = self.viewModel.getFileUrlToExport()
//        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//        if let popover = activityViewController.popoverPresentationController {
//            popover.barButtonItem = navigationItem.rightBarButtonItem
//        }
//        present(activityViewController, animated: true)
    }
    private func getLabelTexts(){
        let stats = viewModel.getItemsTotal()
        
        totalCountLabel.text = "\("total_orders_completed".localized)\(viewModel.itemsForCell.count)"
        
        summaryLabel.text = 
        "💰 \("total_for_the".localized) \(metaData.monthDisplayName(Locale(identifier: "locale".localized))): \(stats.total)"
        summaryLabel.textColor = .systemBlue
        
        dailyAverageLabel.text = String(format: "⚖ \("average_title".localized): %.2f zł", stats.dailyAverage)
        
    }
}

extension ArchiveReviewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.itemsForCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IncomeTableViewCell.reuseIdentifier, for: indexPath) as! IncomeTableViewCell
        
        let item = self.viewModel.itemsForCell[indexPath.row]
        cell.configure(with: item)
//        cell.textLabel?.text = data[indexPath.row]
//        var content = cell.defaultContentConfiguration()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

