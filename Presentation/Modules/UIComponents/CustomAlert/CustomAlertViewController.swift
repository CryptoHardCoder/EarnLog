//
//  CustomAlertViewController.swift
//  EarnLog
//
//  Created by M3 pro on 23/10/2025.
//

import UIKit
import Lottie

final class CustomAlertViewController: UIViewController {

    private let alertView: UIView = {
        let view = UIView()
        view.backgroundColor = DSColors.AlertColors.background
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    private let separatorView: UIView = {
        let separator = UIView()
        separator.backgroundColor = DSColors.gray
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = DSColors.appTextPrimary
        label.numberOfLines = 0
        if #available(iOS 26, *) {
            label.textAlignment = .natural
        } else {
            label.textAlignment = .center
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = DSColors.appTextPrimary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textField: UITextField = {
        let tf = UITextField.makeBaseTextField()
        tf.delegate = self
        return tf
    }()

    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var messageLabelConstraints: [NSLayoutConstraint] = []
    private var animationViewConstraints: [NSLayoutConstraint] = []
    private var textFieldConstraints: [NSLayoutConstraint] = []

    private let alertTitle: String
    private var alertMessage: String? = nil
    private var textFieldText: String? = nil
    private var lottieAnimationFile: LottieAnimationFiles? = nil
    private let actions: [AlertAction]

    var onTextFieldInput: ((String) -> Void)?

    init(alertTitle: String,
                 alertMessage: String?,
                 lottieAnimationFile: LottieAnimationFiles?,
                 textFieldText: String?,
                 actions: [AlertAction]) {
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.lottieAnimationFile = lottieAnimationFile
        self.textFieldText = textFieldText
        self.actions = actions
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        alertView.alpha = 0
        alertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        view.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    private func setupUI() {
        view.addSubview(alertView)
        alertView.addSubview(titleLabel)
        alertView.addSubview(separatorView)
        alertView.addSubview(buttonsStack)

        titleLabel.text = alertTitle

        setupButtons()
        setupBaseConstraints()

        if let lottieAnimationFile = lottieAnimationFile {
            setupAnimationView(with: lottieAnimationFile)
        } else if let textFieldText = textFieldText {
//            setupTextField(with: textFieldText)
            setupTextFieldAlert(with: textFieldText)
        } else {
//            setupMessageLabel()
            setupMessageAlert()
        }
    }

    private func setupBaseConstraints() {
        NSLayoutConstraint.activate([
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),

            titleLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),

            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            separatorView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            buttonsStack.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 44),
            buttonsStack.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -44),
            alertView.bottomAnchor.constraint(equalTo: buttonsStack.bottomAnchor, constant: 20),
        ])
    }

//    private func setupMessageLabel() {
//        messageLabelConstraints = [
//            messageLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20),
//            messageLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
//            messageLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
//
//            buttonsStack.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20)
//        ]
//        NSLayoutConstraint.activate(messageLabelConstraints)
//    }
    private func setupMessageAlert() {
        alertView.addSubview(messageLabel)
        messageLabel.text = alertMessage

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            buttonsStack.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20)
        ])
    }

    private func setupButtons() {
        if actions.count == 2 {
            let horizontalStack = UIStackView()
            horizontalStack.axis = .horizontal
            horizontalStack.distribution = .fillEqually
            horizontalStack.spacing = 30

            for action in actions {
                let button = createButton(for: action)
                horizontalStack.addArrangedSubview(button)
            }
            buttonsStack.addArrangedSubview(horizontalStack)
            horizontalStack.heightAnchor.constraint(equalToConstant: 44).isActive = true
        } else {
            for action in actions {
                let button = createButton(for: action)
                button.heightAnchor.constraint(equalToConstant: 44).isActive = true
                buttonsStack.addArrangedSubview(button)
            }
        }
    }

    private func createButton(for action: AlertAction) -> UIButton {
        let button = UIButton()
        button.setTitle(action.title, for: .normal)
        button.setTitleColor(action.style.textColor, for: .normal)
        button.titleLabel?.font = action.style.font
        button.layer.borderColor = action.style.buttonBorderColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.backgroundColor = action.style.buttonBackgroundColor
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.dismiss(animated: true) {
                action.handler?()
            }
        }), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        button.projectAnimationForButtons()
        if #available(iOS 26, *) {
            let config = UIButton.Configuration.clearGlass()
            button.configuration = config
        }
        return button
    }

    private func setupAnimationView(with animation: LottieAnimationFiles) {

        Task {
            do {
                let dotFile = try await DotLottieFile.named(animation.rawValue)
                let animationView = LottieAnimationView(dotLottie: dotFile)
                animationView.translatesAutoresizingMaskIntoConstraints = false
                animationView.loopMode = .playOnce
                animationView.animationSpeed = animation == .warningAnimation ? 0.5 : 1.2

                await MainActor.run {
                    addAnimationToView(animationView)
                }
            } catch {
                print("Animation file not found: \(error)")
                setupMessageAlert()
            }
        }
    }

    private func addAnimationToView(_ animationView: LottieAnimationView) {
        alertView.addSubview(animationView)
        alertView.addSubview(messageLabel)

        messageLabel.text = alertMessage

        animationViewConstraints = [
            animationView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            animationView.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 100),
            animationView.heightAnchor.constraint(equalToConstant: 100),

            messageLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            buttonsStack.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20)
        ]
        NSLayoutConstraint.activate(animationViewConstraints)

        animationView.animationLoaded = { animView, _ in
            animView.play()
        }
    }

//    private func setupTextField(with text: String) {
//        alertView.addSubview(textField)
//        textField.text = text
//
//        messageLabel.isHidden = true
//        NSLayoutConstraint.deactivate(messageLabelConstraints)
//
//        textFieldConstraints = [
//            textField.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20),
//            textField.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
//            textField.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 44),
//            textField.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -44),
//            textField.heightAnchor.constraint(equalToConstant: 44),
//
//            buttonsStack.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20)
//        ]
//        NSLayoutConstraint.activate(textFieldConstraints)
//    }
    private func setupTextFieldAlert(with text: String) {
        alertView.addSubview(textField)
        textField.text = text

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 44),
            textField.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -44),
            buttonsStack.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20)
        ])
    }

    private func animateIn() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.view.backgroundColor = DSColors.black.withAlphaComponent(0.8)
            self.alertView.alpha = 1
            self.alertView.transform = .identity
            self.view.alpha = 1
        }
    }
}

extension CustomAlertViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text?.trimmingCharacters(in: .whitespaces) {
            onTextFieldInput?(text)
        }
        textField.resignFirstResponder()
        return true
    }
}
