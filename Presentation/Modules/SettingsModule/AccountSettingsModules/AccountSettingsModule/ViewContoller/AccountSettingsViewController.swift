//
//  AccountSettingsViewController.swift
//  EarnLog
//
//  Created by M3 pro on 29/10/2025.
//
import UIKit
import Combine

final class AccountSettingsViewController: UIViewController{
    
        //MARK: - Properties
    private let viewModel: any AccountSettingsViewModelProtocol
    weak var delegate: AccountSettingsViewControllerDelegate?

    private var settingItems = [SettingItem]()
    private var userInfo: UserProfile?

    private var collectionView: UICollectionView?

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: any AccountSettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            delegate?.accountSettingsViewControllerDidFinish(self)
        }
    }

    deinit {
//        print("❌ AccountSettingsViewController deinited")
    }

    private func setupBinding(){
        viewModel.settingItemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] items in
                self?.settingItems = items
                self?.collectionView?.reloadData()
            }
            .store(in: &cancellables)
        viewModel.userInfoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] userInfo in
                self?.userInfo = userInfo
            }
            .store(in: &cancellables)

    }

    private func setupUI(){
        title = "Profile Settings"
        view.backgroundColor = DSColors.appBackground
        
        setupCollectionView()
        setupConstraints()
    }

    private func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.sectionInsetReference = .fromSafeArea
        layout.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        guard let collectionView = collectionView else { return }

        collectionView.register(SettingsCollectionViewCell.self, forCellWithReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }


    private func setupConstraints(){
        guard let collectionView = collectionView else { return }
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func showAlertEditName(){
        guard let userInfo else { return }

        var editedName: String?

        let customAlert = CustomAlert(title: "Edit Name")

        customAlert.withTextField(initialText: userInfo.name) { name in
            editedName = name
        }

        let okAction = AlertAction(title: "Ok", style: .baseDefault) {
            if let editedName,
                editedName != userInfo.name {
                self.viewModel.editName(newName: editedName)
            }
        }

        let cancelAction = AlertAction(title: "Cancel", style: .cancel) {
            self.dismiss(animated: true)
        }

        customAlert.addAction(okAction)
        customAlert.addAction(cancelAction)
        customAlert.showAlert(from: self)
    }

}
    //MARK: - UICollectionViewDataSource
extension AccountSettingsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        settingItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier,
            for: indexPath) as! SettingsCollectionViewCell
        let item = settingItems[indexPath.item]
        cell.configure(title: item.title,
                       font: .monospacedDigitSystemFont(ofSize: 19, weight: .regular),
                       icon: nil, accessoryViewSymbol: UIImage(systemName: "pencil"))
        return cell
    }

}

    //MARK: - UICollectionViewDelegateFlowLayout
extension AccountSettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
}

    //MARK: - UICollectionViewDelegate
extension AccountSettingsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SettingsCollectionViewCell else { return }
        cell.animateTouchForCell()
        let settingItem = settingItems[indexPath.item]
        if settingItem.interactionType == .alert {
            showAlertEditName()
        } else {
            delegate?.accountSettingViewController(self, didSelect: settingItem.destination)
        }

    }
}
