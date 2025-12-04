//
//  EmptyDataView.swift
//  EarnLog
//
//  Created by M3 pro on 20/10/2025.
//
import UIKit
import OSLog

final class EmptyDataView: UIView {
    
        //MARK: - Properties
    private let emptyDataImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

        //MARK: - Initialization / Deinitialization
    init(title: String, description: String ) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        setupUI()

        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "EmptyDataView inited")
        Logger.ui.debug("\(logMessage, align: .left(columns: 10), privacy: .public)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "EmptyDataView deinited")
        Logger.ui.debug("\(logMessage, align: .left(columns: 10), privacy: .public)")
    }

        //MARK: - Setup UI methods

    private func setupUI(){
        setupEmptyDataImageView()
        setupTitleLabel()
        setupDescriptionLabel()
        setupConstraints()
    }
    
    private func setupEmptyDataImageView(){
        emptyDataImageView.image = .emptyData
        emptyDataImageView.backgroundColor = .clear
        emptyDataImageView.contentMode = .scaleAspectFit
        emptyDataImageView.clipsToBounds = true
        emptyDataImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyDataImageView)
    }
    
    private func setupTitleLabel(){
        titleLabel.textColor = DSColors.appTextPrimary
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
    }
    
    private func setupDescriptionLabel(){
        descriptionLabel.textColor = DSColors.appTextPrimary
        descriptionLabel.font = .systemFont(ofSize: 18, weight: .regular)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descriptionLabel)
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            emptyDataImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            emptyDataImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyDataImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: emptyDataImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
        ])
    }
}
