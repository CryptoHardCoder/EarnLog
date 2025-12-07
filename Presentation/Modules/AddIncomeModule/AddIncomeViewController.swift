

import Foundation
import UIKit
import Combine
import OSLog

final class AddIncomeViewController: UIViewController {

    enum AlertType {
        case success
        case error
        case warning
    }
        // MARK: - Properties
    private var viewModel: any AddIncomeViewModelProtocol
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

    private lazy var titleTextField: UITextField = {
        let tf = UITextField.makeBaseTextField(placeholder: "Add Income Title")
        tf.returnKeyType = .next
        return tf
    }()

    private lazy var titleSection = FormSection(
        title: "Income Title",
        textField: titleTextField
    )

    private lazy var descriptionTextField: UITextField = {
        let tf = UITextField.makeBaseTextField(placeholder: "Add Income Description")
        tf.returnKeyType = .next
        return tf
    }()

    private lazy var descriptionSection = FormSection(
        title: "Income Description",
        subtitle: "Optional",
        textField: descriptionTextField
    )

    private lazy  var priceTextField: UITextField = {
        let tf = UITextField.makeBaseTextField(placeholder: "Add income price", keyboardType: .decimalPad)
        tf.inputAccessoryView = inputToolbar
        tf.returnKeyType = .default
        return tf
    }()

    private lazy var priceSection = FormSection(
        title: "Price",
        textField: priceTextField
    )

    private let dateSectionTitle: UILabel = {
        let label = UILabel()
        label.text = "Select Date"
        label.textColor = DSColors.appTextPrimary
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private lazy var dateTextField: UITextField = {
        let tf = UITextField.makeBaseTextField()
        tf.textAlignment = .center
        tf.textColor = DSColors.appPrimary
        tf.isUserInteractionEnabled = true
        return tf
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.maximumDate = .now
        picker.tintColor = DSColors.appPrimary
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.subviews.first?.subviews.first?.subviews.first?.backgroundColor = DSColors.appBackground
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

    private lazy var moneyStateButton = {
        let btn = DSButton.default("Choose money state", size: .large, font: .buttonLarge(weight: .semibold))
        btn.showsMenuAsPrimaryAction = true
        return btn
    }()

    private lazy var sourceButton = {
        let btn = DSButton.default("select_source".localized, size: .large, font: .buttonLarge(weight: .semibold))
        btn.showsMenuAsPrimaryAction = true
        return btn
    }()

    private lazy var saveButton = DSButton.primary("save".localized, size: .large, font: .buttonLarge(weight: .semibold))

    private lazy var inputToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpaceLeft = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexSpaceRight = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(dismissKeyboard))
        doneButton.tintColor = DSColors.appPrimary
        toolbar.delegate = self
        toolbar.setItems([flexSpaceLeft, doneButton, flexSpaceRight], animated: true)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.heightAnchor.constraint(equalToConstant: 44).isActive = true

        return toolbar
    }()

        //MARK: - Initialization / Deinitialization
    init(viewModel: any AddIncomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "AddIncomeViewController inited")
        Logger.ui.debug("\(logMessage, align: .right(columns: 50), privacy: .public)")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit{
        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "AddIncomeViewController deinited")
        Logger.ui.debug("\(logMessage, align: .right(columns: 50), privacy: .public)")
    }
        // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissActiveKeyboard()
        setupUI()
        setupBindings()
        setupActions()
        configureMenus()

        handleDateSelection()

        Task {
            await viewModel.loadData()
        }
        
    }

        // MARK: - Setup UI methods
    private func setupUI() {
        view.backgroundColor = DSColors.appBackground
        navigationItem.title = "Add New Income"

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        [titleSection, descriptionSection, priceSection,
         dateSection, moneyStateButton, sourceButton, saveButton].forEach {
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
        ])
    }

    private func setupTextFieldDelegates() {
        [titleTextField, descriptionTextField, priceTextField].forEach {
            $0.delegate = self
        }
    }

    private func setupBindings() {

        viewModel.viewStatePublisher
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

        // MARK: - Configurations
    private func configureMenus() {
        configureStateMenu()
        configureSourceMenu()
    }

    private func configureStateMenu() {
        let earnedAction = UIAction(title: "Earned") { [weak self] _ in
            self?.moneyStateButton.setTitle("Earned", for: .normal)
            self?.viewModel.isPaid = true
        }

        let expectedAction = UIAction(title: "Expected") { [weak self] _ in
            self?.moneyStateButton.setTitle("Expected", for: .normal)
            self?.viewModel.isPaid = false
        }

        moneyStateButton.menu = UIMenu(children: [earnedAction, expectedAction])
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

    private func resetForms(){
        titleTextField.text = nil
        descriptionTextField.text = nil
        priceTextField.text = nil
        sourceButton.setTitle("select_source".localized, for: .normal)
        moneyStateButton.setTitle("Choose money state", for: .normal)
        dateTextField.text = "Open Calendar"
    }

        // MARK: - Validation methods
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
        let okAction: AlertAction

        switch alertType {
            case .success:
                animationFile = .successAnimation
                okAction = AlertAction(title: "OK", style: .baseDefault) { [weak self] in
                    self?.resetForms()
                    self?.dismiss(animated: true)
                }
            case .error:
                animationFile = .failedAnimation
                okAction = AlertAction(title: "OK", style: .baseDefault) { }
            case .warning:
                animationFile = .warningAnimation
                okAction = AlertAction(title: "OK", style: .baseDefault) { }
        }
        let customAlert = CustomAlert(title: title,
                                      message: message,
                                      animationFile: animationFile)

        customAlert.addAction(okAction)
        customAlert.showAlert(from: self)
    }

    private func showSuccessAlert(message: String) {
        let customAlert = CustomAlert(title: "Success",
                                      message: "New income entry successfully saved",
                                      animationFile: .successAnimation)
        let okAction = AlertAction(title: "OK", style: .baseDefault) { [weak self] in
            self?.resetForms()
//            self?.dismiss(animated: true)
        }
        customAlert.addAction(okAction)
        customAlert.showAlert(from: self)
    }

}

    // MARK: - UITextFieldDelegate
extension AddIncomeViewController: UITextFieldDelegate {

    func findAllTextFields(in view: UIView) -> [UITextField] {
        var fields: [UITextField] = []

        for subview in view.subviews {
            if let tf = subview as? UITextField {
                fields.append(tf)
            }
            fields.append(contentsOf: findAllTextFields(in: subview))
        }
        return fields
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let fields = findAllTextFields(in: self.view)
        guard let index = fields.firstIndex(of: textField) else { return true }

        if index < fields.count - 1 {
            fields[index + 1].becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
    }

}

extension AddIncomeViewController: UIToolbarDelegate {
//    func position(for bar: any UIBarPositioning) -> UIBarPosition {
//        .any
//    }
}


