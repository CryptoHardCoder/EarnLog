////
////  ViewController.swift
////  JobData
////
////  Created by M3 pro on 13/07/2025.
////
//import Foundation
//import UIKit
//
//class MainViewController: UIViewController {
//    
//    private let contentView = UIView()
//    
//    private let scrollView = UIScrollView()
//    
//    private let titleLabel = UILabel()
//    
//    private var goalLeftLabel: UILabel = {
//        let leftlabel = UILabel()
//        leftlabel.text = "goal_for_the_day".localized
//        leftlabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        leftlabel.textColor = .systemBlue
//        return leftlabel
//    }()
//    
//    private var goalTextField = UITextField()
//    
//    private var goalTextFieldContainer = UIView()
//    
//    private let dateLabel = UILabel()
//    
//    private let date = DateFormatter()
//    
//    private var todayDate = String()
//    
//    private let automobileTextField = UITextField()
//    
//    private let priceTextField = UITextField()
//    
//    private let saveButton = UIButton()
//    
//    private let tableView = UITableView()
//    
//    private let segmentController = UISegmentedControl(items: TimeFilter.allCases.map{$0.localizedTitle})
//    
//    private var currentFilterInterval: TimeFilter = .day
//    
//    private var filteredEntries = [CarEntry]()
//    
//    override func loadView() {
//        super.loadView()
//        
//        if AppFileManager.shared.allItems.isEmpty{
//            AppFileManager.shared.loadOrCreateInBackground {
//                print("Мы подтянули данные с файла")
//                
//            }
//        } else {
//            print("Мы данные берем с памяти")
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
////        self.showArchiveTestController()   //вью для тестов архивации
//        
//        view.backgroundColor = .systemBackground
////        navigationController?.navigationBar.isHidden = true
//         
//        hideKeyboard()
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
//        NotificationCenter.default.addObserver(self, selector: #selector(dataDidUpdate), name: .dataDidUpdate, object: nil)
//    }
//    
//    @objc private func dataDidUpdate() {
//        // Просто обновляем UI - данные всегда актуальные из DataManager
//        refreshData()
//    }
//    
//    private func refreshData() {
//        filteredEntries = AppFileManager.shared.getFilteredItems(for: currentFilterInterval)
////        updateSummaryLabel()
//        tableView.reloadData()
//    }
//        
//    private func setupUI() {
//        
//        
//        setupScrollView()
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        
//        titleLabel.text = "earn_log".localized
//        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
//        navigationItem.titleView = titleLabel
////        titleLabel.textAlignment = .center
////        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        goalTextFieldContainer = setupGoalTextFieldView()
//        goalTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
//        
//        date.dateFormat = "dd.MM.yyyy"
//        
//        todayDate = date.string(from: Date())
//        
//        dateLabel.text = "🗓️ \(todayDate)"
//        dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
//        dateLabel.textAlignment = .center
//        dateLabel.textColor = .label
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        automobileTextField.placeholder = "mark_or_model".localized
//        automobileTextField.layer.cornerRadius = 14
//        automobileTextField.layer.borderWidth = 1
//        automobileTextField.layer.borderColor = UIColor.systemGray.cgColor
//        automobileTextField.textAlignment = .center
//        automobileTextField.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        automobileTextField.tag = 1
//        automobileTextField.translatesAutoresizingMaskIntoConstraints = false
//        automobileTextField.addTarget(self, action: #selector(textFieldShouldReturn), for: .editingDidEndOnExit)
//        
//        priceTextField.placeholder = "price".localized
//        priceTextField.layer.cornerRadius = 14
//        priceTextField.layer.borderWidth = 1
//        priceTextField.layer.borderColor = UIColor.systemGray.cgColor
//        priceTextField.textAlignment = .center
//        priceTextField.keyboardType = .decimalPad
//        priceTextField.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        priceTextField.tag = 2
//        priceTextField.translatesAutoresizingMaskIntoConstraints = false
//        priceTextField.addTarget(self, action: #selector(textFieldShouldReturn), for: .touchUpInside)
//        // Создаем toolbar
////        let toolbar = UIToolbar()
////        toolbar.sizeToFit()
////                
////        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
////      // Добавляем flexible space чтобы кнопка была справа
////        let leftFlexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
////        let rightFlexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
////      
////        toolbar.setItems( [leftFlexSpace, doneButton, rightFlexSpace], animated: true)
//      
//      // Устанавливаем toolbar как accessory view
////        priceTextField.inputAccessoryView = toolbar
//        
//        saveButton.setTitle( "save".localized, for: .normal)
//        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
//        saveButton.setTitleColor(.white, for: .normal)
//        saveButton.backgroundColor = .systemBlue
//        saveButton.layer.cornerRadius = 14
//        saveButton.addAnimation()
//        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
//        saveButton.translatesAutoresizingMaskIntoConstraints = false
//
//        // Таблица
//        tableView.dataSource = self
//        tableView.register(IncomeTableViewCell.self,
//                           forCellReuseIdentifier: IncomeTableViewCell.reuseIdentifier)
//        
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.layer.borderColor = UIColor.systemGray.cgColor
//        
//        segmentController.layer.cornerRadius = 14
//        segmentController.backgroundColor = .systemBackground
//        segmentController.selectedSegmentIndex = 0
//        segmentController.setTitleTextAttributes( [.font: UIFont.systemFont(ofSize: 18)], for: .normal)
//        segmentController.addTarget(self, action: #selector(segmentControllerValueChanged), for: .valueChanged)
//        segmentController.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Добавляем вьюхи
//        [/*titleLabel,*/
//         goalTextFieldContainer,
//         dateLabel,
//         automobileTextField,
//         priceTextField,
//         saveButton,
//         tableView,
////         summaryLabel,
//         segmentController].forEach {
//            contentView.addSubview($0)
//        }
//        
//        setupConstraints()
//    }
//    private func setupScrollView(){
//        view.addSubview(scrollView)
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.isUserInteractionEnabled = true
//        scrollView.isScrollEnabled = true
//        scrollView.showsVerticalScrollIndicator = true
//        scrollView.delaysContentTouches = false
//        scrollView.canCancelContentTouches = true
//        scrollView.alwaysBounceVertical = true
//        scrollView.addSubview(contentView)
//    }
//    
//    private func setupConstraints(){
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            
//            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
//            
//            goalTextFieldContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            goalTextFieldContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            goalTextFieldContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70),
//            goalTextFieldContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 70),
//            
//            dateLabel.topAnchor.constraint(equalTo: goalTextFieldContainer.bottomAnchor, constant: 20),
//            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            
//            automobileTextField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
//            automobileTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
//            automobileTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
//            automobileTextField.heightAnchor.constraint(equalToConstant: 60),
//            
//            priceTextField.topAnchor.constraint(equalTo: automobileTextField.bottomAnchor, constant: 30),
//            priceTextField.centerXAnchor.constraint(equalTo: automobileTextField.centerXAnchor),
//            priceTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
//            priceTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
//            priceTextField.heightAnchor.constraint(equalToConstant: 60),
//            
//            saveButton.topAnchor.constraint(equalTo: priceTextField.bottomAnchor, constant: 30),
//            saveButton.centerXAnchor.constraint(equalTo: priceTextField.centerXAnchor),
//            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
//            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
//            saveButton.heightAnchor.constraint(equalToConstant: 50),
//            
//            segmentController.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 30),
//            segmentController.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
//            segmentController.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
//            
////            summaryLabel.topAnchor.constraint(equalTo: segmentController.bottomAnchor, constant: 30),
////            summaryLabel.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
////            summaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 80),
////            summaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -80),
////            summaryLabel.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 30),
//            
//            tableView.topAnchor.constraint(equalTo: segmentController.bottomAnchor, constant: 30),
//            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor/*, constant: 50*/),
//            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor/*, constant: -50*/),
//            tableView.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//
//        ])
//
//}
//    func setupGoalTextFieldView() -> UIView {
//        // Создаем контейнер для текстфилда
//        let containerView = UIView()
//        goalTextField = setupGoalTextField()
//        goalTextField.translatesAutoresizingMaskIntoConstraints = false
//        goalLeftLabel.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(goalLeftLabel)
//        containerView.addSubview(goalTextField)
//        // Настраиваем constraints для goalTextField внутри containerView
//        
//        NSLayoutConstraint.activate([
//            goalLeftLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
//            goalLeftLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
//            goalLeftLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
//            
//            goalTextField.topAnchor.constraint(equalTo: containerView.topAnchor),
//            goalTextField.leadingAnchor.constraint(equalTo: goalLeftLabel.trailingAnchor, constant: 0),
//            goalTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
//        ])
//        
//        let savedGoal = UserDefaults.standard.string(forKey: "dailyGoal") ?? ""
//        goalTextField.text = savedGoal
//        
//        let wasGoalSet = UserDefaults.standard.bool(forKey: "wasGoalSet")
//        
//        if wasGoalSet {
//            goalTextField.isEnabled = false
//        } else {
//            goalTextField.isEnabled = true
//            goalTextField.becomeFirstResponder()
//        }
//        
//        // Добавляем gesture recognizer на контейнер
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(enableEditingGoal))
//        doubleTap.numberOfTapsRequired = 2
//        containerView.addGestureRecognizer(doubleTap)
//        
//        goalTextField.addTarget(self, action: #selector(saveGoal), for: .editingDidEnd)
//        goalTextField.addTarget(self, action: #selector(saveGoal), for: .editingDidEndOnExit)
//        
//        return containerView
//    }
// 
//    func setupGoalTextField() -> UITextField {
//        let textField = UITextField()
//        textField.placeholder = "0"
//        textField.textColor = .systemBlue
//        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        textField.textAlignment = .center
//        textField.keyboardType = .numberPad
//        
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let doneButton = UIBarButtonItem(title: "Done",
//                                         style: .done,
//                                         target: self,
//                                         action: #selector(dismissKeyboard))
//
//        toolbar.setItems([flexSpace, doneButton, UIBarButtonItem.flexibleSpace()], animated: false)  // ❗ Обязательно flexSpace
//        textField.inputAccessoryView = toolbar
//
//        return textField
//    }
//    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//
//    @objc func enableEditingGoal() {
//        goalTextField.isEnabled = true
//        goalTextField.becomeFirstResponder()
//        UserDefaults.standard.set(true, forKey: "wasEditing") // Сохраняем состояние редактирования
//    }
//
//    @objc func saveGoal() {
//        guard let text = goalTextField.text, !text.isEmpty else { return }
//        UserDefaults.standard.set(text, forKey: "dailyGoal")
//        UserDefaults.standard.set(true, forKey: "wasGoalSet")
//        UserDefaults.standard.set(false, forKey: "wasEditing") // Сбрасываем состояние редактирования
//        
//        let target = Double(text) ?? 0
//        UserDefaults.standard.set(target, forKey: "targetValue")
//        NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
//        goalTextField.resignFirstResponder()
//        goalTextField.isEnabled = false
//    }
//
//    @objc private func segmentControllerValueChanged() {
//        currentFilterInterval = TimeFilter.allCases[segmentController.selectedSegmentIndex]
////        filteredEntries = AppFileManager.shared.getFilteredItems(for: currentFilterInterval)
//        refreshData()
//    }
//    
//    private func showAlert(){
//        let alert = UIAlertController(title: "error".localized, message: "error_empty".localized, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    
//    @objc func saveButtonTapped() {
//        guard let car = automobileTextField.text,
//              let priceText = priceTextField.text,
//              let price = Double(priceText),
//              !car.isEmpty else { showAlert(); return }
//
//        let newEntry = CarEntry(date: Date(), car: car, price: price, isPaid: false)
//        AppFileManager.shared.addNewItem(newEntry)
////        tableView.reloadData()
//        automobileTextField.text = ""
//        priceTextField.text = ""
//        view.endEditing(true)
//        NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
//    }
//    
//}
//
//extension MainViewController: UITextFieldDelegate, UITableViewDataSource {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if let nextField = view.viewWithTag(textField.tag + 1) as? UITextField {
//            nextField.becomeFirstResponder() // Переключиться на следующее поле
//        } else {
//            textField.resignFirstResponder() // Закрыть клавиатуру
//        }
//        return true
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredEntries.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: IncomeTableViewCell.reuseIdentifier,
//                                                 for: indexPath) as! IncomeTableViewCell
//        
//        
//        let entry = filteredEntries[indexPath.row]
//        cell.configure(with: entry)
//        
//        // Настройка callback для чекмарка
//        cell.onCheckmarkTapped = { [weak self] in
//            if let self = self {
//                AppFileManager.shared.togglePaymentStatus(for: entry.id)
//                self.filteredEntries = AppFileManager.shared.getFilteredItems(for: self.currentFilterInterval)
//                NotificationCenter.default.post(name: .dataDidUpdate, object: nil)
////                print(self.filteredEntries)
////                tableView.reloadData()
//            }
//        }
//        return cell
//        
//    }
//}
