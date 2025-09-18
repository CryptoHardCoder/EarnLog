//
//  HistoryViewController.swift
//  JobData
//
//  Created by M3 pro on 13/07/2025.
//

import UIKit

final class HistoryViewController: UIViewController, MemoryTrackable {
    
    private let viewModel = HistoryViewModel()
    
    private let titleLabel = UILabel()
    
    private let tableView = UITableView()
    
    private var dateTextField: UITextField?
    private var datePicker: UIDatePicker?
    
    private let functionsButton = UIButton()
    
    //    private var summaryTimeInterval = [String]()
    
    //    private var filteredEntries: [CarEntry] = []
    
    private let segmentController = UISegmentedControl(items: TimeFilter.allCases.map{$0.localizedTitle})
    
    private var currentFilterInterval: TimeFilter = .day
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 15 // 👉 между строками
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: label.font as Any
        ]
        
        label.attributedText = NSAttributedString(string: "...", attributes: attributes)
        return label
    }()
    
    private var isSelectionMode = false
    private var selectedIndexPaths: Set<IndexPath> = []
    
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
        setupDefaultNavigationItems()
        bindViewModel()
        setupNotifications()
        setupUI()
    }
    //////////////////////////////////
    private func setupNotifications(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dataDidUpdate),
                                               name: .dataDidUpdate,
                                               object: nil)
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
        trackDeallocation()
    }
    
    @objc private func dataDidUpdate() {
        viewModel.refreshData()
    }
    
    private func bindViewModel() {
        // 📢 Слушаем изменения данных
        viewModel.onDataChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.selectedIndexPaths.removeAll()
                self?.updateSummaryLabel()
                self?.tableView.reloadData()
            }
        }
        
    // 🔄 Слушаем сброс UI состояния
      viewModel.onResetUIState = { [weak self] in
          DispatchQueue.main.async {
              // Сбрасываем режим выбора
              self?.isSelectionMode = false
              self?.selectedIndexPaths.removeAll()
              self?.updateNavigationButtons()
          }
      }
        
    }
    
    private func setupDefaultNavigationItems(){
        titleLabel.text = "history".localized
        titleLabel.font = .systemFont(ofSize: 25, weight: .semibold)
        navigationItem.titleView = titleLabel
        
        // Создаем меню в зависимости от режима
        updateNavigationButtons()
    }
    
    private func updateNavigationButtons() {
        if !isSelectionMode {
            // ОБЫЧНЫЙ РЕЖИМ: показываем "Выбрать" и "Выбрать все"
            let selectAction = UIAction(title: "select".localized) { _ in
                self.enterSelectionMode()
            }
            
            let selectAllAction = UIAction(title: "select_all".localized) { _ in
                self.enterSelectionModeAndSelectAll()
            }
            
            let showAllItemsAction = UIAction(title: "show_all_items".localized) { _ in
                self.viewModel.getAllItemsAndResetUI()
                self.segmentController.selectedSegmentIndex = UISegmentedControl.noSegment
            }
            
            let menu = UIMenu(title: "", children: [selectAction, selectAllAction, showAllItemsAction])
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "ellipsis.circle"),
                style: .plain,
                target: nil,
                action: nil
            )
            navigationItem.rightBarButtonItem?.menu = menu
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "square.and.arrow.up"),
                style: .plain,
                target: self,
                action: #selector(exportData)
            )
            
            
        } else {
            let cancel = UIButton()
            cancel.setTitle("cancel".localized, for: .normal)
            cancel.setTitleColor(.systemRed, for: .normal)
            cancel.addTarget(self, action: #selector(exitSelectionMode), for: .touchUpInside)
            // РЕЖИМ ВЫБОРА: показываем только кнопку "Отмена"
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancel)
            
            let removeAction = UIAction(title: "delete_selected".localized, image: UIImage(systemName: "trash"), attributes: .destructive){ _ in
                self.showDeleteAllert()
                
            }
            
            removeAction.attributes = selectedIndexPaths.isEmpty ? [.disabled] : [.destructive]
            
            let changeStatusPay = UIAction(title: "change_pay_status".localized, image: UIImage(systemName: "dollarsign.arrow.circlepath")){ _ in
                self.showChangeStatusPayAlert()
                //                print(self.viewModel.filteredEntries)
            }
            
            changeStatusPay.attributes = selectedIndexPaths.isEmpty ? [.disabled] : []
            
            let rightButtonMenu = UIMenu(title: "", children: [changeStatusPay, removeAction])
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "square.and.pencil"),
                style: .plain,
                target: nil,
                action: nil
            )
            
            navigationItem.leftBarButtonItem?.menu = rightButtonMenu
            
        }
    }
 
    private func showDeleteAllert(){
        let alert = UIAlertController(title: "delete_entry".localized,
                                      message: "confirm_delete".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .default))
        alert.addAction(UIAlertAction(title: "yes".localized, style: .destructive) { _ in
            let idsToDelete = self.selectedIndexPaths.map { self.viewModel.filteredEntries[$0.row].id }
            idsToDelete.forEach { self.viewModel.deleteItem(entryId: $0) }
            
            self.isSelectionMode = false
            self.updateNavigationButtons()
        })
        
        present(alert, animated: true)
    }
    
    private func showChangeStatusPayAlert(for indexPath: IndexPath? = nil) {
        let changeAlert = UIAlertController(
            title: "change_pay_status".localized,
            message: indexPath == nil
            ? "change_status_selected_all".localized
            : "change_status_select_one".localized,
            preferredStyle: .actionSheet
        )
        
        changeAlert.addAction(UIAlertAction(title: "paid_for_alert".localized , style: .default) { _ in
            self.applyStatusChange(newStatus: true, for: indexPath)
        })
        
        changeAlert.addAction(UIAlertAction(title: "unpaid_for_alert".localized , style: .default) { _ in
            self.applyStatusChange(newStatus: false, for: indexPath)
        })
        
        changeAlert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        
        present(changeAlert, animated: true)
    }
    
    private func applyStatusChange(newStatus: Bool, for indexPath: IndexPath?) {
        if let indexPath = indexPath {
            // Работаем только с одной записью
            let entryItem = viewModel.filteredEntries[indexPath.row]
            viewModel.updateItem(entryId: entryItem.id, newStatus: newStatus)
//            print("// Работаем только с одной записью")
        } else {
            // Работаем с выбранными записями
//            print("// Работаем с выбранными записями")
            let entryItemsIds = selectedIndexPaths.map {indexPath in viewModel.filteredEntries[indexPath.row].id }
            viewModel.updateItem(entiresIds: entryItemsIds, newStatus: newStatus)
            
//            for indexPath in selectedIndexPaths {
//                let entryItemsIds = selectedIndexPaths.map {indexPath in viewModel.filteredEntries[indexPath.row].id }
//                print(entryItemsIds)
////                let entryItem = viewModel.filteredEntries[indexPath.row]
//                viewModel.updateItem(entiresIds: entryItemsIds, newStatus: newStatus)
//            }
            isSelectionMode = false
            updateNavigationButtons()
        }
    }
    
    private func enterSelectionMode() {
        isSelectionMode = true
        selectedIndexPaths.removeAll()
        
        // Показываем checkmark кнопки (все пустые)
        tableView.reloadData()
        
        // Обновляем navigation bar - теперь справа будет "Отмена"
        updateNavigationButtons()
        
//        print("Вошли в режим выбора")
    }
    
    private func enterSelectionModeAndSelectAll() {
        isSelectionMode = true
        selectedIndexPaths.removeAll()
        
        // Выбираем все элементы
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                selectedIndexPaths.insert(IndexPath(row: row, section: section))
            }
        }
        
        // Показываем checkmark кнопки (все выбранные)
        tableView.reloadData()
        
        // Обновляем navigation bar - теперь справа будет "Отмена"
        updateNavigationButtons()
        
//        print("Вошли в режим выбора и выбрали все (\(selectedIndexPaths.count) элементов)")
    }
    
    @objc private func exitSelectionMode() {
        isSelectionMode = false
        selectedIndexPaths.removeAll()
        
        // Скрываем checkmark кнопки
        tableView.reloadData()
        
        // Обновляем navigation bar - возвращаем меню с многоточием
        updateNavigationButtons()
        
//        print("Вышли из режима выбора")
    }

    
    @objc private func exportData() {
        let alert = UIAlertController(title: "export_data".localized,
                                      message: "select_export_format".localized,
                                      preferredStyle: .actionSheet)
        
        func handleExport(_ format: FileFormat){
            let result = self.viewModel.exportToFormat(format)
            switch result{
                case .success(let url):
                    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    if let popover = activityViewController.popoverPresentationController {
                        popover.barButtonItem = navigationItem.rightBarButtonItem
                    }
                    present(activityViewController, animated: true)
                case .failure(_):
                    showAlert(title: "error".localized, message: "export_failed".localized)
            }
        }
        alert.addAction(UIAlertAction(title: "CSV", style: .default) { _ in
            handleExport(.csv)
        })
        
        alert.addAction(UIAlertAction(title: "PDF", style: .default) { _ in
            handleExport(.pdf)
        })
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupUI() {
        segmentController.layer.cornerRadius = 14
        segmentController.backgroundColor = .systemBackground
        segmentController.selectedSegmentIndex = UISegmentedControl.noSegment
        segmentController.setTitleTextAttributes( [.font: UIFont.systemFont(ofSize: 18)], for: .normal)
        segmentController.addTarget(self, action: #selector(segmentControllerValueChanged), for: .valueChanged)
        
        summaryLabel.text = "..."
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(IncomeTableViewCell.self, forCellReuseIdentifier: IncomeTableViewCell.reuseIdentifier)
        tableView.layer.borderColor = UIColor.systemGray.cgColor
        
        
        [segmentController, summaryLabel, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setupConsraints()
        
    }
    
    private func setupConsraints() {
        NSLayoutConstraint.activate([
            segmentController.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentController.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            summaryLabel.topAnchor.constraint(equalTo: segmentController.bottomAnchor, constant: 20),
            summaryLabel.centerXAnchor.constraint(equalTo: segmentController.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            
        ])
    }
    
    
    @objc private func segmentControllerValueChanged() {
        viewModel.changeFilterByIndex(segmentController.selectedSegmentIndex) // 🏃‍♂️ ViewModel меняет фильтр
    }
    
    
    // MARK: - Обновление статистики
    private func updateSummaryLabel() {
        let total = viewModel.getTotalToSummaryLabel()
        summaryLabel.text = String(format: "\("total_amount".localized): %.0f zł", total)
    }
    
    
    private func showEditAlert(for entry: IncomeEntry) {
        let alert = UIAlertController(title: "edit".localized, message: "edit_values".localized, preferredStyle: .alert)
        
        // Сохраняем исходные значения для сравнения
        let originalCar = entry.car
        let originalPrice = entry.price
        let originalDate = entry.date
        
        // Добавляем текстфилды с предзаполнением
        alert.addTextField { textField in
            textField.placeholder = "car_name".localized
            textField.text = originalCar
            textField.clearButtonMode = .whileEditing
        }
        
        alert.addTextField { textField in
            textField.placeholder = "price".localized
            textField.text = "\(originalPrice)"
            textField.keyboardType = .decimalPad
            textField.clearButtonMode = .whileEditing
        }
        
        alert.addTextField { [weak self] textField in
            guard let self = self else { return }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            
            textField.placeholder = "date_(dd.mm.yyyy)".localized
            textField.text = formatter.string(from: originalDate)
            
            // Создаём UIDatePicker
            let picker = UIDatePicker()
            picker.datePickerMode = .date
            picker.preferredDatePickerStyle = .wheels
            picker.date = originalDate
//            picker.locale = Locale(identifier: "ru_RU")
            picker.maximumDate = Date()
            // ✅ Устанавливаем минимальную дату - начало текущего месяца
            let calendar = Calendar.current
            let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start
            picker.minimumDate = startOfMonth
            
            picker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
            
            // Сохраняем ссылки
            self.datePicker = picker
            self.dateTextField = textField
            
            textField.inputView = picker
            textField.clearButtonMode = .never
            //            textField.tag = 999
            //            
            //            // Добавим кнопку "Готово"
            //            let toolbar = UIToolbar()
            //            toolbar.sizeToFit()
            //            // ИСПРАВЛЕНО: Указываем self как target
            //            let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(self.datePickerDoneTapped))
            //            toolbar.setItems([UIBarButtonItem.flexibleSpace(), doneButton], animated: false)
            //            
            //            textField.inputAccessoryView = toolbar
        }
        
        let saveAction = UIAlertAction(title: "save".localized, style: .default) { [weak self] _ in
            guard let self = self,
                  let carTextField = alert.textFields?[0],
                  let priceTextField = alert.textFields?[1],
                  let dateTextField = alert.textFields?[2] else { return }
            
            // Получаем новые значения
            let newCarText = carTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let newPriceText = priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let newDateText = dateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            
            if let errorMessage = self.validateEditValues(car: newCarText,
                                                          price: newPriceText,
                                                          date: newDateText,
                                                          formatter: formatter) {
                self.showValidationError(message: errorMessage)
                self.showEditAlert(for: entry)
                return
            }
            
            let newValues = self.getChangedValues(original: entry,
                                                  new: (car: newCarText,
                                                        price: newPriceText,
                                                        date: newDateText),
                                                  formatter: formatter)
            
            // Сохраняем только если есть изменения
            if newValues.hasChanges {
                self.viewModel.updateItem(entryId: entry.id,
                                          entryCar: newValues.car,
                                          entryPrice: newValues.price,
                                          entryDate: newValues.date)
                
//                print("✅ Изменения сохранены")
            } else {
//                print("ℹ️ Изменений не было, сохранение не требуется")
            }
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        self.dateTextField?.text = formatter.string(from: sender.date)
//        print("✅ Date changed to: \(formatter.string(from: sender.date))")
    }
    
    
    private func getChangedValues(original: IncomeEntry, new: (car: String, price: String, date: String), formatter: DateFormatter) -> (car: String?, price: Double?, date: Date?, hasChanges: Bool) {
        
        var newCar: String? =  nil
        var newPrice: Double? = nil
        var newDate: Date? = nil
        
        if !new.car.isEmpty && new.car != original.car {
            newCar = new.car
//            print("Машина изменена: '\(original.car)' → '\(new.car)'")
        }
        
        if let priceValue = Double(new.price), priceValue != original.price {
            newPrice = priceValue
//            print("Цена изменена: \(original.price) → \(new.price)")
        }
        
        if let dateValue = formatter.date(from: new.date), dateValue != original.date {
            newDate = dateValue
//            print("Дата изменена: \(original.date) → \(new.date)")
        }
        
        let hasChanges = newCar != nil || newPrice != nil || newDate != nil
        return (newCar, newPrice, newDate, hasChanges)
    }
    
    private func validateEditValues(car: String,
                                    price: String,
                                    date: String,
                                    formatter: DateFormatter) -> String?{
        
        if car.isEmpty { return "car_name_empty".localized }
        
        if price.isEmpty || Double(price) == nil { return "price_must_be_number".localized }
        
        if date.isEmpty || formatter.date(from: date) == nil { return "date_invalid".localized }
        
        return nil
    }
    
    // Показать ошибку валидации
    private func showValidationError(message: String) {
        let errorAlert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(errorAlert, animated: true)
    }
}
extension HistoryViewController: UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.viewModel.filteredEntries.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IncomeTableViewCell.reuseIdentifier, for: indexPath) as! IncomeTableViewCell
        // 🔒 Проверка границ
        guard indexPath.row < viewModel.filteredEntries.count else {
               return cell // Возвращаем пустую ячейку
        }
           
        let item = self.viewModel.filteredEntries[indexPath.row]
        let isSelected = selectedIndexPaths.contains(indexPath)
        
        // Передаем текущий режим и состояние выбора
        cell.configure(with: item, isSelectionMode: isSelectionMode, isSelected: isSelected)
        
        cell.onCheckmarkTapped = { [weak self] in
            guard let self = self, self.isSelectionMode else { return }
            
            // Переключаем состояние выбора
            if self.selectedIndexPaths.contains(indexPath) {
                self.selectedIndexPaths.remove(indexPath)
                //TODO: Спросить нормально ли каждый раз так перенастраивать navigationBar
                self.updateNavigationButtons()
            } else {
                self.selectedIndexPaths.insert(indexPath)
                self.updateNavigationButtons()
            }
            
            // ВАЖНО: Обновляем только состояние кнопки, не всю ячейку
            if let cell = self.tableView.cellForRow(at: indexPath) as? IncomeTableViewCell {
                let isSelected = self.selectedIndexPaths.contains(indexPath)
                let item = self.viewModel.filteredEntries[indexPath.row] 
                
                // Вызываем configure без пересоздания layout
                cell.configure(with: item, isSelectionMode: self.isSelectionMode, isSelected: isSelected)
            }
            
//            print("Выбрано строк: \(self.selectedIndexPaths.count)")
//            print("selectedIndexPaths: \(self.selectedIndexPaths)")
        }
        return cell
    }
        
        func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                
                let deleteAction = UIAction(title: "delete".localized, image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                    let entryToDelete = self.viewModel.filteredEntries[indexPath.row]
                    
                    let deleteAlert = UIAlertController(title: "delete_entry".localized,
                                                        message: "confirm_delete".localized,
                                                        preferredStyle: .alert)
                    
                    deleteAlert.addAction(UIAlertAction(title: "yes".localized, style: .destructive) { _ in
                        self.viewModel.deleteItem(entryId: entryToDelete.id)
                    })
                    
                    deleteAlert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
                    
                    // Просто показываем alert от текущего view controller-а
                    self.present(deleteAlert, animated: true)
                }
                
                let editAction = UIAction(title: "edit".localized, image: UIImage(systemName: "pencil")) { _ in
                    //                print("Редактируем ячейку \(indexPath.row)")
                    
                    let entryToEdit = self.viewModel.filteredEntries[indexPath.row]
                    self.showEditAlert(for: entryToEdit)
                }
                
                let changeStatusPay = UIAction(title: "change_pay_status".localized, image: UIImage(systemName: "dollarsign.arrow.circlepath")){ _ in
                    self.showChangeStatusPayAlert(for: indexPath)
                }

                return UIMenu(title: "", children: [editAction, changeStatusPay, deleteAction])
            }
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
//            print("didSelectRowAt")
        }
    }


    
  

