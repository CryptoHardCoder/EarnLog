//
//  SettingsViewController.swift
//  EarnLog
//
//  Created by M3 pro on 29/07/2025.
//

import UIKit
import PhotosUI

final class SettingsViewController: UIViewController {

    private let viewModel: any SettingsViewModelProtocol

    weak var delegate: SettingsViewControllerDelegate?

    private var collectionView: UICollectionView?

    private var dataSource: UICollectionViewDiffableDataSource<SettingsSection, SettingItem>!

    init(viewModel: any SettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applySnapshot()
    }

    private func setupUI(){
        title = "Settings"
//        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = DSColors.appBackground
        setupCollectionView()
        configureDataSource()
        setupConstraints()

    }

    private func setupCollectionView(){
        let layout = createCompositionalLayout()

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        guard let collectionView = collectionView else { return }

        collectionView.register(AvatarCollectionViewCell.self,
                                forCellWithReuseIdentifier: AvatarCollectionViewCell.reuseIdentifier)
        collectionView.register(SettingsCollectionViewCell.self,
                                forCellWithReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier)

        collectionView.register(SectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeaderView.identifier)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in

                // Секция с аватаром
            if sectionIndex == 0 {
                return self.createAvatarSection()
            }

                // Обычные секции настроек
            return self.createSettingsSection()
        }

            // Регистрируем decoration view для фона секций
        layout.register(SectionBackgroundView.self, forDecorationViewOfKind: "SectionBackground")

        return layout
    }

    private func createAvatarSection() -> NSCollectionLayoutSection {
            // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30)

        return section
    }

    private func createSettingsSection() -> NSCollectionLayoutSection {
            // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 50, bottom: 30, trailing: 50)
        section.interGroupSpacing = 0

            // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading,
            absoluteOffset: CGPoint(x: -20, y: 0)
        )
        section.boundarySupplementaryItems = [header]

            // Decoration для фона секции
        let background = NSCollectionLayoutDecorationItem.background(elementKind: "SectionBackground")
        background.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 25, bottom: 10, trailing: 25)
        section.decorationItems = [background]

        return section
    }

    private func setupConstraints(){
        guard let collectionView = collectionView else { return }

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

        // MARK: - Diffable Data Source
    private func configureDataSource() {
        guard let collectionView = collectionView else { return }
        dataSource = UICollectionViewDiffableDataSource<SettingsSection, SettingItem>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in

                if indexPath.section == 0 {
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: AvatarCollectionViewCell.reuseIdentifier,
                        for: indexPath
                    ) as! AvatarCollectionViewCell
                    cell.configure(image: .avatar)
                    return cell
                }

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as! SettingsCollectionViewCell

                cell.configure(title: item.title, icon: item.icon, accessoryViewSymbol: nil)
                return cell
            }
        )

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.identifier,
                for: indexPath
            ) as! SectionHeaderView

            let section = self.viewModel.settingsData[indexPath.section]
            header.configure(text: section.title ?? "")
            return header
        }
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SettingsSection, SettingItem>()
        let sections = viewModel.settingsData
        snapshot.appendSections(sections)
        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func handleAvatarTap() {
        print("Avatar tapped!")

        let avatarVC = AvatarSelectionView()
        avatarVC.delegate = self

        if let sheet = avatarVC.sheetPresentationController {
            sheet.detents = [.custom(resolver: { context in 280 })]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(avatarVC, animated: true)
    }

    private func openPhotoLibrary() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

        // MARK: - Update Avatar
    private func updateAvatar(_ image: UIImage) {
        // Обновить аватар в ячейке коллекции
        if let collectionView = collectionView {
            let indexPath = IndexPath(item: 0, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? AvatarCollectionViewCell {
                cell.configure(image: image)
            }
        }

        // Здесь можно сохранить изображение (UserDefaults, Core Data, Firebase и т.д.)
    }

}

    //MARK: - UICollectionViewDelegate
extension SettingsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            handleAvatarTap()
            return
        }
        // Анимация выделения
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.animateTouchForCell()
        }

        let item = viewModel.settingsData[indexPath.section].items[indexPath.item]

        delegate?.settingsViewController(self, didSelect: item.destination)

        collectionView.deselectItem(at: indexPath, animated: true)
    }

}

    // MARK: - PHPickerViewControllerDelegate
extension SettingsViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.updateAvatar(image)
                }
            }
        }
    }
}

    // MARK: - UIImagePickerControllerDelegate
extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        if let image = image {
            updateAvatar(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

    // MARK: - AvatarSelectionDelegate
extension SettingsViewController: AvatarSelectionDelegate {
    func didSelectChoosePhoto() {
        openPhotoLibrary()
    }

    func didSelectTakePhoto() {
        openCamera()
    }
}
