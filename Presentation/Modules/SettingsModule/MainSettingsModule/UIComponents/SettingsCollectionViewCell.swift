//
//  SettingsCollectionViewCell.swift
//  EarnLog
//
//  Created by M3 pro on 26/10/2025.
//
import UIKit

final class SettingsCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "SettingsCollectionViewCell"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private var textField: UITextField?
    private var accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
    private var titleLeadingConstraint: NSLayoutConstraint!

    override init(frame: CGRect){
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(){
        titleLabel.textColor = DSColors.appTextPrimary
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .natural
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        accessoryView.contentMode = .scaleAspectFit
        accessoryView.tintColor = DSColors.appTextSecondary
        accessoryView.translatesAutoresizingMaskIntoConstraints = false

        let separatorView = UIView()
        separatorView.backgroundColor = DSColors.appTextSecondary
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(accessoryView)
        contentView.addSubview(separatorView)

        titleLeadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5)

        NSLayoutConstraint.activate([

            titleLeadingConstraint,
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: accessoryView.leadingAnchor),

            accessoryView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            accessoryView.widthAnchor.constraint(equalToConstant: 24),
            accessoryView.heightAnchor.constraint(equalToConstant: 24),

            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func setupIconView(){
        iconView.tintColor =  DSColors.appTextSecondary
        iconView.contentMode = .scaleAspectFit
        iconView.clipsToBounds = true
        iconView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(iconView)
        titleLeadingConstraint.isActive = false
        NSLayoutConstraint.activate([
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
        ])
    }

    func configure(title: String, font: UIFont? = nil, icon: UIImage? = nil, accessoryViewSymbol: UIImage? = nil ) {
        titleLabel.text = title
        if let font { titleLabel.font = font }
        if let icon {
            iconView.image = icon
            setupIconView()
        }
        if let accessoryViewSymbol { accessoryView.image = accessoryViewSymbol }
    }

}
