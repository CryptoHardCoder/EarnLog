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
        view.backgroundColor = .alertBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    private let separatorView: UIView = {
        let separator = UIView()
        separator.backgroundColor = .black300
        separator.translatesAutoresizingMaskIntoConstraints = false

        return separator
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .designBlack
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
        label.textColor = .designBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let alertTitle: String
    private let alertMessage: String
    private let lottieAnimationFile: LottieAnimationFiles?
    private let actions: [AlertAction]

    init(alertTitle: String,
         alertMessage: String,
         lottieAnimationFile: LottieAnimationFiles? = nil,
         actions: [AlertAction]) {
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.lottieAnimationFile = lottieAnimationFile
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

    private func setupUI(){
        view.addSubview(alertView)
        alertView.addSubview(separatorView)

        alertView.addSubview(titleLabel)
        titleLabel.text = alertTitle

        alertView.addSubview(messageLabel)
        messageLabel.text = alertMessage

        alertView.addSubview(buttonsStack)
        setupButtons()

        if let lottieAnimationFile {
            setupAnimationView(with: lottieAnimationFile)
            setupConstraints(withAnimationView: true)
        } else {
            setupConstraints(withAnimationView: false)
        }


    }

    private func setupButtons(){
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
        button.addAction(UIAction(handler: { [ weak self] _ in
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

    private func setupConstraints(withAnimationView: Bool){
        if withAnimationView {
            messageLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20).isActive = false
        } else {
            messageLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20).isActive = true
        }
        NSLayoutConstraint.activate([
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),

            titleLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -10),

            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            separatorView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            messageLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),

            buttonsStack.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            buttonsStack.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 44),
            buttonsStack.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -44),

            alertView.bottomAnchor.constraint(equalTo: buttonsStack.bottomAnchor, constant: 20),
        ])

    }

    private func setupAnimationView(with animation: LottieAnimationFiles){
        Task {
            do {
                let dotFile = try await DotLottieFile.named(animation.rawValue)
                let animationView = LottieAnimationView(dotLottie: dotFile)
                animationView.translatesAutoresizingMaskIntoConstraints = false
                animationView.loopMode = .playOnce
                if animation == .warningAnimation{
                    animationView.animationSpeed = 0.5
                } else {
                    animationView.animationSpeed = 1.2
                }
                await MainActor.run {
                    addAnimationToView(animationView)
                }

            } catch {
                print("Animation file not fined: \(error)")
            }
        }
    }

    private func addAnimationToView(_ animationView: LottieAnimationView){
        alertView.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            animationView.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 100),
            animationView.heightAnchor.constraint(equalToConstant: 100),

            messageLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor)
        ])
        animationView.animationLoaded = { animView, anim in
            animView.play()
        }
    }

    private func animateIn(){
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.view.backgroundColor = .black.withAlphaComponent(0.8)
            self.alertView.alpha = 1
            self.alertView.transform = .identity
            self.view.alpha = 1

        }
    }

}

