//
//  AvatarCollectionViewCell.swift
//  EarnLog
//
//  Created by M3 pro on 02/11/2025.
//
import UIKit

final class AvatarCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "AvatarCollectionViewCell"

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let cameraImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "camera.on.rectangle"))
        imageView.image?.withRenderingMode(.alwaysOriginal)

        imageView.contentMode = .center
        imageView.tintColor = DSColors.appPrimary
//        imageView.backgroundColor = DSColors.appBackground
        imageView.layer.cornerRadius = 17
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        layer.shadowColor = DSColors.shadowColor.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 12

        contentView.addSubview(avatarImageView)
        contentView.addSubview(cameraImage)

        NSLayoutConstraint.activate([
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),

            cameraImage.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 5),
            cameraImage.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
            cameraImage.widthAnchor.constraint(equalToConstant: 34),
            cameraImage.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let avatarPoint = cameraImage.convert(point, from: self)
        if cameraImage.bounds.contains(avatarPoint) {
            return cameraImage
        }
        return nil
    }

    func configure(image: UIImage?) {
        avatarImageView.image = image
    }

}
