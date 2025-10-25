

import Foundation
import UIKit
import Combine

// MARK: - AddIncomeViewController
final class AddIncomeViewController: UIViewController {

    enum AlertType {
        case success
        case error
        case warning
    }
    // MARK: - Properties
    private let viewModel = AppDependencies.shared.addIncomeViewModel
    private var cancellables = Set<AnyCancellable>()
    private var sideJobs: [String] = [] {
        didSet { configureSourceMenu() }
    }
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.keyboardDismissMode = .interactive
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 30
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var titleTextField = createTextField(
        placeholder: "Add Income Title",
        keyboardType: .default
    )
    
    private lazy var titleSection = FormSection(
        title: "Income Title",
        textField: titleTextField
    )
    
    private lazy var descriptionTextField = createTextField(
        placeholder: "Add Income Description",
        keyboardType: .default
    )
    
    private lazy var descriptionSection = FormSection(
        title: "Income Description",
        subtitle: "Optional",
        textField: descriptionTextField
    )
    
    private lazy  var priceTextField: UITextField = {
        let tf = createTextField(placeholder: "Add income price", keyboardType: .decimalPad)
        tf.inputAccessoryView = inputToolbar
        return tf
    }()
    
    private lazy var priceSection = FormSection(
        title: "Price",
        textField: priceTextField
    )
    
    private let dateSectionTitle: UILabel = {
        let label = UILabel()
        label.text = "Select Date"
        label.textColor = .designBlack
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var dateTextField: UITextField = {
        let tf = createTextField(placeholder: "", keyboardType: .default)
        tf.layer.borderWidth = 0
        tf.textAlignment = .center
        tf.text = "Open Calendar"
        tf.textColor = .designPrimary
        tf.isUserInteractionEnabled = true
        return tf
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
//        picker.date = .now
        picker.preferredDatePickerStyle = .inline
        picker.maximumDate = .now
        picker.tintColor = .designPrimary
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var dateSection = DatePickerSection(
        title: dateSectionTitle, 
        dateTextField: dateTextField,
        datePicker: datePicker,
        onDateSelected: { [weak self] in
            self?.handleDateSelection()
        }
    )
    
    private lazy var stateButton = createMenuButton(title: "Choose money state")
    private lazy var sourceButton = createMenuButton(title: "select_source".localized)
    
    private lazy var saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("save".localized, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        btn.setTitleColor(.designBackground, for: .normal)
        btn.backgroundColor = .designPrimary
        btn.layer.cornerRadius = 10
        btn.projectAnimationForButtons()
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var inputToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        doneButton.tintColor = .designPrimary
        toolbar.items = [flexSpace, doneButton, flexSpace]
        toolbar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return toolbar
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideActiveKeyboard()
        setupUI()
        setupBindings()
        setupActions()
        configureMenus()
        
        Task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .designBackground
        navigationItem.title = "Add New Income"
        navigationItem.largeTitleDisplayMode = .automatic
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        [titleSection, descriptionSection, priceSection, 
         dateSection, stateButton, sourceButton, saveButton].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        setupConstraints()
        setupTextFieldDelegates()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            stateButton.heightAnchor.constraint(equalToConstant: 50),
            sourceButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupTextFieldDelegates() {
        [titleTextField, descriptionTextField, priceTextField].forEach {
            $0.delegate = self
        }
    }
    
    private func setupBindings() {
        
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .ready: break
                case .loading: break
//                    self?.showLoadingIndicator()
                    case .loaded(let newData):
                        self?.sideJobs = newData
//                    self?.hideLoadingIndicator()
                case .error(let message):
                        self?.showAlert(title: "Error ❌", message: message, alertType: .error)
                case .success(let message):
                        self?.showAlert(title: "Successfully", message: message, alertType: .success)
                }
            }
            .store(in: &cancellables)

    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    private func configureMenus() {
        configureStateMenu()
        configureSourceMenu()
    }
    
    private func configureStateMenu() {
        let earnedAction = UIAction(title: "Earned") { [weak self] _ in
            self?.stateButton.setTitle("Earned", for: .normal)
            self?.viewModel.isPaid = true
        }
        
        let expectedAction = UIAction(title: "Expected") { [weak self] _ in
            self?.stateButton.setTitle("Expected", for: .normal)
            self?.viewModel.isPaid = false
        }
        
        stateButton.menu = UIMenu(children: [earnedAction, expectedAction])
    }
    
    private func configureSourceMenu() {
        var actions: [UIMenuElement] = []
        
        // Main job
        let mainJobName = viewModel.mainJobName
        let mainJobAction = UIAction(title: mainJobName) { [weak self] _ in
            self?.sourceButton.setTitle(mainJobName, for: .normal)
            self?.viewModel.selectSource(sourceName: mainJobName)
        }
        actions.append(mainJobAction)
        
        // Side jobs
        let sideJobActions = sideJobs.map { jobName in
            UIAction(title: jobName) { [weak self] _ in
                self?.sourceButton.setTitle(jobName, for: .normal)
                self?.viewModel.selectSource(sourceName: jobName)
            }
        }
        
        if !sideJobActions.isEmpty {
            let sideJobMenu = UIMenu(title: "part_time".localized, children: sideJobActions)
            actions.append(sideJobMenu)
        }
        
        sourceButton.menu = UIMenu(children: actions)
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard validateInputs(), let priceDouble = priceTextField.text?.toDouble() else { return }

        Task {
            await viewModel.saveNewItem(
                title: titleTextField.text!,
                description: descriptionTextField.text,
                price: priceDouble,
                date: datePicker.date
            )
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func handleDateSelection() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        dateTextField.text = formatter.string(from: datePicker.date)
    }
    
    // MARK: - Validation
    private func validateInputs() -> Bool {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(title: "Error ❌", message: "Please enter income title", alertType: .error)
            return false
        }

        guard let priceText = priceTextField.text, 
              !priceText.isEmpty,
              priceText.toDouble() != nil else {
            showAlert(title: "Error ❌", message: "Please enter valid price", alertType: .error)
            return false
        }
        
        return true
    }
    
    // MARK: - Alerts
    private func showAlert(title: String, message: String, alertType: AlertType) {
        let animationFile: LottieAnimationFiles
        
        switch alertType {
            case .success:
                animationFile = .successAnimation
            case .error:
                animationFile = .failedAnimation
            case .warning:
                animationFile = .warningAnimation
        }
        let customAlert = CustomAlert(title: title,
                                      message: message,
                                      animationFile: animationFile)
        let okAction = AlertAction(title: "OK", style: .baseDefault) { [weak self] in

        }
        customAlert.addAction(okAction)
        customAlert.showAlert(from: self)
    }
    
    private func showSuccessAlert(message: String) {
        let customAlert = CustomAlert(title: "Success",
                                      message: "New income entry successfully saved",
                                      animationFile: .successAnimation)
        let okAction = AlertAction(title: "OK", style: .baseDefault) { [weak self] in
            self?.resetForms()
            self?.dismiss(animated: true)
        }
        customAlert.addAction(okAction)
        customAlert.showAlert(from: self)
    }
    
    private func resetForms(){
        titleTextField.text = nil
        descriptionTextField.text = nil
        priceTextField.text = nil
        sourceButton.setTitle("select_source".localized, for: .normal)
        stateButton.setTitle("Choose money state", for: .normal)
        dateTextField.text = "Open Calendar"
    }
    
    // MARK: - Factory Methods
    private func createTextField(placeholder: String, keyboardType: UIKeyboardType) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.keyboardType = keyboardType
        tf.autocapitalizationType = .sentences
        tf.returnKeyType = .done
        tf.font = .systemFont(ofSize: 20, weight: .semibold)
        tf.textColor = .designBlack
        tf.layer.borderColor = UIColor.designBlack.withAlphaComponent(0.6).cgColor
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 10
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tf
    }
    
    private func createMenuButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.designPrimary, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.designBlack.withAlphaComponent(0.6).cgColor
        btn.layer.cornerRadius = 10
        btn.showsMenuAsPrimaryAction = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }
}

// MARK: - UITextFieldDelegate
extension AddIncomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
    }

}

