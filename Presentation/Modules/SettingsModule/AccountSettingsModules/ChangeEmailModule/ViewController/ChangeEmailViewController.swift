//
//  ChangeEmailViewController.swift
//  EarnLog
//
//  Created by M3 pro on 16/11/2025.
//
import Foundation
import UIKit
import Combine
import OSLog

final class ChangeEmailViewController: UIViewController {

        //MARK: - Properties
    private var viewModel: any ChangeEmailViewModelProtocol

        //MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private let imageView: UIImageView = {
        let imageVw = UIImageView()
        imageVw.image = .avatar
        imageVw.contentMode = .scaleAspectFill
        imageVw.clipsToBounds = true
        imageVw.translatesAutoresizingMaskIntoConstraints = false

        return imageVw
    }()
    private lazy var emailTextField: UITextField = {
        let tf = UITextField.makeBaseTextField(placeholder: "Email", keyboardType: .emailAddress)
        tf.delegate = self
        return tf
    }()

    private lazy var emailTextFieldSection = FormSection(title: "Email", textField: emailTextField)

    private let validationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    private let sendButton = {
        let button = DSButton.primary("Send", size: .large, font: .buttonLarge(weight: .semibold))
        button.isEnabled = false

        return button
    }()

    private var cancellables = Set<AnyCancellable>()

    var onEmailSended: (()->Void)?
    
    //MARK: - Initialization / Deinitialization

    init(viewModel: any ChangeEmailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        dismissActiveKeyboard()

        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "ChangeEmailViewController inited")
        Logger.ui.debug("\(logMessage, privacy: .public)")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "ChangeEmailViewController deinited")
        Logger.ui.debug("\(logMessage, privacy: .public)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
        setupKeyboardHandling()
    }

    override func beginAppearanceTransition(_ isAppearing: Bool, animated: Bool) {
        super.beginAppearanceTransition(isAppearing, animated: animated)

        contentView.animateSlideInFromRight(translationX: view.bounds.maxX)
    }

    private func setupBinding(){
        viewModel.isEmailValidPublisher
            .receive(on: DispatchQueue.main)
            .sink {  [weak self] value in
                self?.updateValidationUI(isValid: value)
            }
            .store(in: &cancellables)

        emailTextField.publisher(for: \.text)
            .compactMap { $0 }
            .sink { [weak self] text in
                self?.viewModel.email = text
                print("\(text)")
            }
            .store(in: &cancellables)
    }

    private func updateValidationUI(isValid: Bool) {
        guard let confirmText = emailTextField.text, !confirmText.isEmpty else {
            emailTextField.text = ""
            return
        }

        validationLabel.text = isValid ? "✅ Correct email address" : "❌ Incorrect email address"
        validationLabel.textColor = isValid ? DSColors.success : DSColors.error

        emailTextField.layer.borderColor = isValid ? DSColors.success.cgColor : DSColors.error.cgColor

        sendButton.isEnabled = isValid
        sendButton.alpha = isValid ? 1 : 0.5
    }


    private func setupUI(){
        title = "Change Email"
        view.backgroundColor = DSColors.appBackground
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: [.touchUpInside, .touchUpOutside])

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(emailTextFieldSection)
        contentView.addSubview(validationLabel)
        contentView.addSubview(sendButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            emailTextFieldSection.topAnchor.constraint(equalTo: contentView.topAnchor, constant: view.bounds.height / 2.5),
            emailTextFieldSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            emailTextFieldSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),

            validationLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
            validationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            validationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),

            sendButton.topAnchor.constraint(equalTo: validationLabel.bottomAnchor, constant: 50),
            sendButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            sendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),

            contentView.bottomAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 30)
        ])
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
            bottom: isShowing ? keyboardFrame.height : 0, //so that validation labels are visible
            right: 0
        )
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }

    @objc
    private func sendButtonTapped(){
        Task{
            await viewModel.submitChangeEmail()
        }
        onEmailSended?()
    }

}

extension ChangeEmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
