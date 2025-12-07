//
//  ChangePasswordViewController.swift
//  EarnLog
//
//  Created by M3 pro on 14/11/2025.
//
import Foundation
import UIKit
import Combine
import OSLog

protocol ChangePasswordViewControllerDelegate: AnyObject {
    func changePasswordViewControllerDidFinish(_ changePasswordViewController: UIViewController)
    func changePasswordViewControllerForgotPassword(_ changePasswordViewController: UIViewController)
}

final class ChangePasswordViewController: UIViewController {

        // MARK: - Private Properties

    private let viewModel: any ChangePasswordViewModelProtocol

        // MARK: - Private UI Properties

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let confirmPasswordMatchLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
//    private let activityIndicator: UIActivityIndicatorView = {
//        let indicator = UIActivityIndicatorView(style: .medium)
//        indicator.hidesWhenStopped = true
//        indicator.translatesAutoresizingMaskIntoConstraints = false
//        return indicator
//    }()

    private lazy var currentPasswordTextField = UITextField.makePasswordField(placeholder: "Current Password")

    private lazy var newPasswordTextField = UITextField.makePasswordField(
        placeholder: "New Password",
        textContentType: .newPassword
    )

    private lazy var confirmPasswordTextField = UITextField.makePasswordField(
        placeholder: "Confirm Password",
        textContentType: .newPassword
    )

    private lazy var currentPasswordSection = FormSection(
        title: "Current Password",
        textField: currentPasswordTextField
    )

    private lazy var newPasswordSection = FormSection(
        title: "New Password",
        textField: newPasswordTextField
    )

    private lazy var confirmPasswordSection = FormSection(
        title: "Confirm Password",
        textField: confirmPasswordTextField
    )

    private let currentPasswordValidationView = PasswordValidationView()
    private let newPasswordValidationView = PasswordValidationView()
    private let submitButton = DSButton.primary(
        "Change Password",
        size: .large,
        font: .buttonLarge(weight: .semibold)
    )

    private let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot password?", for: .normal)
        button.setTitleColor(DSColors.gray, for: .normal)
        button.setTitleColor(DSColors.appPrimary, for: .highlighted)
        button.titleLabel?.font = DSTypography.heading3(weight: .semibold).font
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


        // MARK: - Reactive Properties

    private var cancellables = Set<AnyCancellable>()

    weak var delegate: ChangePasswordViewControllerDelegate?
        // MARK: - Initialization / Deinitialization

    init(viewModel: any ChangePasswordViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "ChangePasswordViewController inited")
        Logger.ui.debug("\(logMessage, align: .left(columns: 10), privacy: .public)")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "ChangePasswordViewController deinited")
        Logger.ui.debug("\(logMessage, align: .left(columns: 10), privacy: .public)")
    }

        // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
        setupActions()
        setupKeyboardHandling()
        dismissActiveKeyboard()
    }

    override func beginAppearanceTransition(_ isAppearing: Bool, animated: Bool) {
        super.beginAppearanceTransition(isAppearing, animated: animated)
        contentView.animateSlideInFromRight(translationX: view.bounds.maxX)
    }

        // MARK: - Private Methods

    private func setupBinding() {
            // Current password validation
        viewModel.currentPasswordValidationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.currentPasswordValidationView.update(with: state)
            }
            .store(in: &cancellables)

            // New password validation
        viewModel.newPasswordValidationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.newPasswordValidationView.update(with: state)
            }
            .store(in: &cancellables)

            // Confirm password matching
        viewModel.confirmPasswordValidationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateConfirmPasswordLabel(isMatching: state.isMatching)
            }
            .store(in: &cancellables)

            // Submit button enabled state
        viewModel.isSubmitEnabledPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.submitButton.isEnabled = isEnabled
                self?.submitButton.alpha = isEnabled ? 1.0 : 0.5
            }
            .store(in: &cancellables)

            // Text field changes
        currentPasswordTextField.publisher(for: \.text)
            .compactMap { $0 }
            .sink { [weak self] text in
                self?.viewModel.validateCurrentPassword(text)
            }
            .store(in: &cancellables)

        newPasswordTextField.publisher(for: \.text)
            .compactMap { $0 }
            .sink { [weak self] text in
                self?.viewModel.validateNewPassword(text)
                if let confirmText = self?.confirmPasswordTextField.text {
                    self?.viewModel.validateConfirmPassword(confirmText, against: text)
                }
            }
            .store(in: &cancellables)

        confirmPasswordTextField.publisher(for: \.text)
            .compactMap { $0 }
            .sink { [weak self] text in
                if let newPassword = self?.newPasswordTextField.text {
                    self?.viewModel.validateConfirmPassword(text, against: newPassword)
                }
            }
            .store(in: &cancellables)
    }

    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)

            // Set delegates for text fields
        currentPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self

            // Set return key types
        currentPasswordTextField.returnKeyType = .next
        newPasswordTextField.returnKeyType = .next
        confirmPasswordTextField.returnKeyType = .done
    }

    @objc private func submitButtonTapped() {
        guard let oldPassword = currentPasswordTextField.text,
              let newPassword = newPasswordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            return
        }

        view.endEditing(true)
//        setLoading(true)

        Task { [weak self] in
            guard let self = self else { return }

            do {
                try await self.viewModel.submit(
                    oldPassword: oldPassword,
                    newPassword: newPassword,
                    confirmPassword: confirmPassword
                )

                await MainActor.run {
//                    self.setLoading(false)
                    self.showSuccessAlert()
                }
            } catch let error as PasswordUIError {
                await MainActor.run {
//                    self.setLoading(false)
                    self.showError(error)
                }
            }
        }
    }

    @objc
    private func forgotPasswordButtonTapped(){
        showDefaultAlert()

    }

    

//    private func setLoading(_ loading: Bool) {
//        submitButton.isEnabled = !loading
//        if loading {
//            activityIndicator.startAnimating()
//        } else {
//            activityIndicator.stopAnimating()
//        }
//    }

    private func showDefaultAlert(){
        let alert = CustomAlert(title: "Forgot password?", message: "Do you forgot current password?")
        let okAction = AlertAction(title: "Yes", style: .baseDefault) { [unowned self] in
            self.delegate?.changePasswordViewControllerForgotPassword(self)
        }
        let cancelAction = AlertAction(title: "No", style: .destructive) {

        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.showAlert(from: self)
    }

    private func showSuccessAlert() {

        let alert = CustomAlert(title: "Success", message: "Your password has been changed successfully", animationFile: .successAnimation)

        let okAction = AlertAction(title: "Ok", style: .baseDefault) { [unowned self] in
            self.delegate?.changePasswordViewControllerDidFinish(self)
        }
        alert.addAction(okAction)
        alert.showAlert(from: self)
    }

    func showError(_ error: PasswordUIError) {
        let message: String
        let okActionHandler: (()->Void)?
        switch error {
            case .validation(let validationError):
                message = validationError.localizedDescription
                okActionHandler = { [weak self] in
                    guard let self else { return }
                    switch validationError {
                        case .currentPasswordInvalid:
                            self.currentPasswordTextField.becomeFirstResponder()
                        case .newPasswordInvalid:
                            self.newPasswordTextField.becomeFirstResponder()
                        case .passwordsDoNotMatch:
                            self.confirmPasswordTextField.becomeFirstResponder()
                        case .passwordEqualToOld:
                            self.newPasswordTextField.becomeFirstResponder()
                    }
                }
            case .server(let error):
                message = error
                okActionHandler = { [weak self] in
                    self?.dismiss(animated: true)
                }
        }

        let alert = CustomAlert(title: "Error", message: message, animationFile: .failedAnimation)
        let okAction = AlertAction(title: "Ok", style: .baseDefault, handler: okActionHandler)
        alert.addAction(okAction)
        alert.showAlert(from: self)
    }

    private func updateConfirmPasswordLabel(isMatching: Bool) {
        guard let confirmText = confirmPasswordTextField.text, !confirmText.isEmpty else {
            confirmPasswordMatchLabel.text = ""
            return
        }
        confirmPasswordMatchLabel.text = isMatching ? "✅ Passwords match" : "❌ Passwords do not match"
        confirmPasswordMatchLabel.textColor = isMatching ? DSColors.success : DSColors.error
        confirmPasswordTextField.layer.borderColor = isMatching ? DSColors.success.cgColor : DSColors.error.cgColor
    }

    private func setupKeyboardHandling() {

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue }
            .sink { [weak self] keyboardFrame in
                self?.adjustForKeyboard(keyboardFrame: keyboardFrame, isShowing: true)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.adjustForKeyboard(keyboardFrame: .zero, isShowing: false)
            }
            .store(in: &cancellables)
    }

    private func adjustForKeyboard(keyboardFrame: CGRect, isShowing: Bool) {
        let contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: isShowing ? keyboardFrame.height + 40 : 0, //so that validation labels are visible
            right: 0
        )
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }

    private func setupUI() {
        title = "Change Password"
        view.backgroundColor = DSColors.appBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(currentPasswordSection)
        contentView.addSubview(currentPasswordValidationView)
        contentView.addSubview(newPasswordSection)
        contentView.addSubview(newPasswordValidationView)
        contentView.addSubview(confirmPasswordSection)
        contentView.addSubview(confirmPasswordMatchLabel)
        contentView.addSubview(submitButton)
        contentView.addSubview(forgotPasswordButton)
//        contentView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Current Password Section
            currentPasswordSection.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            currentPasswordSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currentPasswordSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Current Password Validation
            currentPasswordValidationView.topAnchor.constraint(equalTo: currentPasswordSection.bottomAnchor, constant: 10),
            currentPasswordValidationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currentPasswordValidationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // New Password Section
            newPasswordSection.topAnchor.constraint(equalTo: currentPasswordValidationView.bottomAnchor, constant: 24),
            newPasswordSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            newPasswordSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // New Password Validation
            newPasswordValidationView.topAnchor.constraint(equalTo: newPasswordSection.bottomAnchor, constant: 10),
            newPasswordValidationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            newPasswordValidationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Confirm Password Section
            confirmPasswordSection.topAnchor.constraint(equalTo: newPasswordValidationView.bottomAnchor, constant: 24),
            confirmPasswordSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmPasswordSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Confirm Password Match Label
            confirmPasswordMatchLabel.topAnchor.constraint(equalTo: confirmPasswordSection.bottomAnchor, constant: 10),
            confirmPasswordMatchLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmPasswordMatchLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Submit Button
            submitButton.topAnchor.constraint(equalTo: confirmPasswordMatchLabel.bottomAnchor, constant: 10),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            forgotPasswordButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor/*, constant: 12*/),
            forgotPasswordButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            forgotPasswordButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
//
//
//            // Activity Indicator
//            activityIndicator.centerXAnchor.constraint(equalTo: forgotPasswordButton.centerXAnchor),
//            activityIndicator.centerYAnchor.constraint(equalTo: forgotPasswordButton.centerYAnchor)
        ])

            // Initial state
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
    }
}

    // MARK: - UITextFieldDelegate
extension ChangePasswordViewController: UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case currentPasswordTextField:
                newPasswordTextField.becomeFirstResponder()
            case newPasswordTextField:
                confirmPasswordTextField.becomeFirstResponder()
            case confirmPasswordTextField:
                confirmPasswordTextField.resignFirstResponder()
                if submitButton.isEnabled {
                    submitButtonTapped()
                }
            default:
                textField.resignFirstResponder()
        }
        return true
    }
}
