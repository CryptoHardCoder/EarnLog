////
////  HistoryViewController.swift
////  EarnLog
////
////  Created by M3 pro on 30/07/2025.
////
//
//
////
////  HistoryViewController.swift
////  JobData
////
////  Created by M3 pro on 13/07/2025.
////
//
//import UIKit
//
//class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    
//    private let titleLAbel = UILabel()
//    
//    private let tableView = UITableView()
//    
//    private var summaryTimeInterval = [String]()
//    
//    private var filteredEntries: [CarEntry] = []
//    
//    private let segmentController = UISegmentedControl(items: TimeFilter.allCases.map{$0.localizedTitle})
//    
//    private var currentFilterInterval: TimeFilter = .day
//    
//    private let summaryLabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.textColor = .systemBlue
//        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 15 // 👉 между строками
//        paragraphStyle.alignment = .center
//        
//        let attributes: [NSAttributedString.Key: Any] = [
//            .paragraphStyle: paragraphStyle,
//            .font: label.font as Any
//        ]
//        
//        label.attributedText = NSAttributedString(string: "...", attributes: attributes)
//        return label
//    }()
//    
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = .systemBackground
////        navigationController?.navigationBar.isHidden = true
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            image: UIImage(systemName: "square.and.arrow.up"),
//            style: .plain,
//            target: self,
//            action: #selector(exportData)
//        )
//        
//        setupNotifications()
//        setupUI()
//        refreshData()
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    private func setupNotifications(){
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(dataDidUpdate),
//                                               name: .dataDidUpdate,
//                                               object: nil)
//    }
//    
//    private func refreshData() {
//        filteredEntries = AppFileManager.shared.getFilteredItems(for: currentFilterInterval)
//        updateSummaryLabel()
//        tableView.reloadData()
//    }
//    
//    @objc private func dataDidUpdate() {
//        // Просто обновляем UI - данные всегда актуальные из DataManager
//        refreshData()
//    }
//    
//    @objc private func exportData() {
//        let alert = UIAlertController(title: "export_data".localized, message: "select_export_format".localized, preferredStyle: .actionSheet)
//        
//        alert.addAction(UIAlertAction(title: "CSV", style: .default) { _ in
//            self.exportToFormat(.csv)
//        })
//        
//        alert.addAction(UIAlertAction(title: "JSON", style: .default) { _ in
//            self.exportToFormat(.json)
//        })
//        
//        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
//        
//        if let popover = alert.popoverPresentationController {
//            popover.barButtonItem = navigationItem.rightBarButtonItem
//        }
//        
//        present(alert, animated: true)
//    }
//    
//    private enum ExportFormat {
//        case csv, json
//    }
//    
//    private func exportToFormat(_ format: ExportFormat) {
////        let items = AppFileManager.shared.getFilteredItems(for: currentFilterInterval)  // Получаем текущие отфильтрованные данные
//        
//        let fileURL: URL?
//        
//        switch format {
//        case .csv:
//            fileURL = AppFileManager.shared.exportCSV(items: filteredEntries, period: currentFilterInterval)
//        case .json:
//            fileURL = AppFileManager.shared.exportJSON(items: filteredEntries, period: currentFilterInterval)
//        }
//        
//        guard let url = fileURL else {
//            showAlert(title: "error".localized, message: "export_failed".localized )
//            return
//        }
//        
//        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//        
//        if let popover = activityViewController.popoverPresentationController {
//            popover.barButtonItem = navigationItem.rightBarButtonItem
//        }
//        
//        present(activityViewController, animated: true)
//    }
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    private func setupUI() {
//        
//        titleLAbel.text = "history".localized
//        titleLAbel.font = .systemFont(ofSize: 25, weight: .semibold)
//        navigationItem.titleView = titleLAbel
//        
//        segmentController.layer.cornerRadius = 14
//        segmentController.backgroundColor = .systemBackground
//        segmentController.selectedSegmentIndex = UISegmentedControl.noSegment
//        segmentController.setTitleTextAttributes( [.font: UIFont.systemFont(ofSize: 18)], for: .normal)
//        segmentController.addTarget(self, action: #selector(segmentControllerValueChanged), for: .valueChanged)
//        
//        summaryLabel.text = "..."
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(IncomeTableViewCell.self, forCellReuseIdentifier: IncomeTableViewCell.reuseIdentifier)
//        tableView.layer.borderColor = UIColor.systemGray.cgColor
//        
//        
//        [segmentController, summaryLabel, tableView].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview($0)
//        }
//        
//        setupConsraints()
//        
//    }
//    
//    func setupConsraints() {
//        NSLayoutConstraint.activate([
//            segmentController.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            segmentController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            segmentController.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            summaryLabel.topAnchor.constraint(equalTo: segmentController.bottomAnchor, constant: 20),
//            summaryLabel.centerXAnchor.constraint(equalTo: segmentController.centerXAnchor),
//            
//            tableView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20),
//            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
//            
//        ])
//    }
//    
//    
//    @objc private func segmentControllerValueChanged() {
//        currentFilterInterval = TimeFilter.allCases[segmentController.selectedSegmentIndex]
//        refreshData()
//    }
//    
//         
//    // MARK: - Обновление статистики
//    private func updateSummaryLabel() {
//        let total = filteredEntries.reduce(0) { $0 + $1.price }
//        summaryLabel.text = String(format: "\("total_amount".localized): %.0f zł", total)
//    }
//    
//    private func showEditAlert(for entry: CarEntry) {
//        let alert = UIAlertController(title: "edit".localized, message: "edit_values".localized, preferredStyle: .alert)
//        
//        // Сохраняем исходные значения для сравнения
//        let originalCar = entry.car
//        let originalPrice = entry.price
//        let originalDate = entry.date
//        
//        // Добавляем текстфилды с предзаполнением
//        alert.addTextField { textField in
//            textField.placeholder = "car_name".localized
//            textField.text = originalCar
//            textField.clearButtonMode = .whileEditing
//        }
//        
//        alert.addTextField { textField in
//            textField.placeholder = "price".localized
//            textField.text = "\(originalPrice)"
//            textField.keyboardType = .decimalPad
//            textField.clearButtonMode = .whileEditing
//        }
//        
//        alert.addTextField { textField in
//            let formatter = DateFormatter()
//            formatter.dateFormat = "dd.MM.yyyy"
//            textField.placeholder = "date_(dd.mm.yyyy)".localized
//            textField.text = formatter.string(from: originalDate)
//            textField.clearButtonMode = .whileEditing
//        }
//        
//        let saveAction = UIAlertAction(title: "save".localized, style: .default) {_ in
//            guard let carTextField = alert.textFields?[0],
//                  let priceTextField = alert.textFields?[1],
//                  let dateTextField = alert.textFields?[2] else { return }
//            
//            // Получаем новые значения
//            let newCarText = carTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//            let newPriceText = priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//            let newDateText = dateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//            
//            let formatter = DateFormatter()
//            formatter.dateFormat = "dd.MM.yyyy"
//            
//            // ВАЛИДАЦИЯ: Проверяем, что обязательные поля не пустые
//            if newCarText.isEmpty {
//                self.showValidationError(message: "car_name_empty".localized)
//                self.showEditAlert(for: entry)
//            }
//            
//            if newPriceText.isEmpty || Double(newPriceText) == nil {
//                self.showValidationError(message: "price_must_be_number".localized)
//                self.showEditAlert(for: entry)
//            }
//            if newDateText.isEmpty || formatter.date(from: newDateText) == nil {
//                self.showValidationError(message: "date_invalid".localized)
//                self.showEditAlert(for: entry)
//            }
//            
//            // Проверяем, что РЕАЛЬНО изменилось
//            var newCar: String? = nil
//            var newPrice: Double? = nil
//            var newDate: Date? = nil
//            var hasChanges = false
//            
//            // Проверяем изменение машины
//            if !newCarText.isEmpty && newCarText != originalCar {
//                newCar = newCarText
//                hasChanges = true
//                print("Машина изменена: '\(originalCar)' → '\(newCarText)'")
//            }
//
//            // Проверяем изменение цены
//            if let newPriceValue = Double(newPriceText), newPriceValue != originalPrice {
//                newPrice = newPriceValue
//                hasChanges = true
//                print("Цена изменена: \(originalPrice) → \(newPriceValue)")
//            }
//            
//            if let parsedDate = formatter.date(from: newDateText), parsedDate != originalDate {
//                newDate = parsedDate
//                hasChanges = true
//                print("Дата изменена: \(originalDate) → \(parsedDate)")
//            }
//            // Сохраняем только если есть изменения
//            if hasChanges {
//                AppFileManager.shared.updateItem(for: entry.id,
//                                                 newCar: newCar,
//                                                 newPrice: newPrice,
//                                                 newDate: newDate)
//                AppFileManager.shared.saveItemsToFile()
//                
//                // Обновляем уведомлением
//                NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
//                
//                print("✅ Изменения сохранены")
//            } else {
//                print("ℹ️ Изменений не было, сохранение не требуется")
//            }
//        }
//        
//        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel)
//        
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//        
//        self.present(alert, animated: true)
//    }
//    
//    // Показать ошибку валидации
//    private func showValidationError(message: String) {
//        let errorAlert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
//        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(errorAlert, animated: true)
//    }
//
//    
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredEntries.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: IncomeTableViewCell.reuseIdentifier, for: indexPath) as! IncomeTableViewCell
//        
//        let entry = filteredEntries[indexPath.row]
//        cell.configure(with: entry)
//        cell.onCheckmarkTapped = { [weak self] in
//            if let self = self {
//                AppFileManager.shared.togglePaymentStatus(for: entry.id)
//                self.filteredEntries = AppFileManager.shared.getFilteredItems(for: self.currentFilterInterval)
//                refreshData()
//            }
//        }
//        return cell
//        
//    }
//    
//    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
//            
//            let deleteAction = UIAction(title: "delete".localized, image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
//                let entryToDelete = self.filteredEntries[indexPath.row]
//                   
//                let deleteAlert = UIAlertController(title: "delete_entry".localized,
//                                                    message: "confirm_delete".localized,
//                                                    preferredStyle: .alert)
//                   
//                deleteAlert.addAction(UIAlertAction(title: "yes".localized, style: .destructive, handler: { _ in
//                       AppFileManager.shared.deleteItem(withId: entryToDelete.id)
//                       AppFileManager.shared.saveItemsToFile()
//                       NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
//                   }))
//                   
//                deleteAlert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
//
//                   // Просто показываем alert от текущего view controller-а
//                   self.present(deleteAlert, animated: true)
//            }
//            
//            let editAction = UIAction(title: "edit".localized, image: UIImage(systemName: "pencil")) { _ in
////                print("Редактируем ячейку \(indexPath.row)")
//               
//                let entryToEdit = self.filteredEntries[indexPath.row]
//                self.showEditAlert(for: entryToEdit)
//            }
//                
//                
////                AppFileManager.shared.updateItem(for: entryToEdit.id, newCar: <#T##String?#>, newPrice: <#T##Double?#>)
//            return UIMenu(title: "", children: [editAction, deleteAction])
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}
