//
//  PartTimeJobsSettingsViewController.swift
//  EarnLog
//
//  Created by M3 pro on 12/08/2025.
//

import Foundation
import UIKit

final class PartTimeJobsSettingsViewController: UIViewController, MemoryTrackable{
    
    private let viewModel = PartTimeJobsSettingsViewModel()
    
    private let descriptionLabel = UILabel()
    
    private let partTimeJobsTableView = UITableView(frame: .zero, style: .plain)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        trackCreation()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.title = "edit_part_time_jobs".localized
        
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(dataDidUpdate), 
                                               name: .dataDidUpdate, 
                                               object: nil)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium)
            
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(addNewSideJob))
        
        viewModel.onDataChanged = { [weak self] in
            self?.partTimeJobsTableView.reloadData()
//            	print("viewModel.onDataChanged")
        }
        
        descriptionLabel.text = "edit_part_time_description".localized
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .systemGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        partTimeJobsTableView.delegate = self
        partTimeJobsTableView.dataSource = self
        partTimeJobsTableView.register(PartTimeJobsCell.self, forCellReuseIdentifier: PartTimeJobsCell.reuseIdentifier)
        partTimeJobsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(partTimeJobsTableView)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            descriptionLabel.bottomAnchor.constraint(equalTo: partTimeJobsTableView.topAnchor, constant: 30),
            
            partTimeJobsTableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            partTimeJobsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            partTimeJobsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            partTimeJobsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        
    }
    
    // В PartTimeJobsSettingsViewController добавьте:
    deinit {
//        print("🗑️ PartTimeJobsSettingsViewController deinit")
        NotificationCenter.default.removeObserver(self)
        trackDeallocation()
    }
    
    @objc private func dataDidUpdate() {
       viewModel.refreshData() // 🏃‍♂️ ViewModel обновляет данные
    }
    
    @objc private func addNewSideJob(){
        viewModel.addNewSideJob(newSideJobName: "new_sidejob".localized)
        if let newSideJobIndex = viewModel.partTimeJobs.firstIndex(where: { $0.name == "new_sidejob".localized }) {
            let indexPath = IndexPath(row: newSideJobIndex, section: 0)
            partTimeJobsTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            // Ждем, пока ячейка вставится, и активируем TextField
            DispatchQueue.main.async {
                if let cell = self.partTimeJobsTableView.cellForRow(at: indexPath) as? PartTimeJobsCell {
                    cell.startEditing()
                }
            }
        }
        
        
    }
}


extension PartTimeJobsSettingsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.partTimeJobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PartTimeJobsCell.reuseIdentifier, for: indexPath) as! PartTimeJobsCell
        
        let job = self.viewModel.partTimeJobs[indexPath.row]
        
        cell.configure(text: job.name)
        
        cell.onTextChanged = { [weak self] newText in
            self?.viewModel.updateJobName(id: job.id, newName: newText)
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "delete".localized) { _, _, completion in
            let deleteJob = self.viewModel.partTimeJobs[indexPath.row]
            self.viewModel.deleteSideJob(id: deleteJob.id)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
}
