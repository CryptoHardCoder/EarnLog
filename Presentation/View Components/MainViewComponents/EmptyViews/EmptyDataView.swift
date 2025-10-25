//
//  EmptyDataView.swift
//  EarnLog
//
//  Created by M3 pro on 20/10/2025.
//
import UIKit

final class EmptyDataView: UIView, MemoryTrackable {
    let emptyDataImageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    
    init(title: String, description: String ) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        setupUI()
        trackCreation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        titleLabel.textColor = .designBlack
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
    }
    
    private func setupDescriptionLabel(){
        descriptionLabel.textColor = .designBlack
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
