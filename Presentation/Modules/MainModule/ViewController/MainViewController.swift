//
//  MainViewController.swift
//  JobData
//
import Foundation
import UIKit
import Combine
import OSLog

final class MainViewController: UIViewController {

        // MARK: - Private Properties
    private let viewModel: any MainViewModelProtocol
    private var cancellables: Set<AnyCancellable> = []
    private var lastContentOffset: CGFloat = 0
    private var currentData: MainViewData?

        // MARK: - State Properties
    private enum GoalViewState {
        case notSetUp
        case empty
        case withData
    }

    private enum EntriesViewState {
        case notSetUp
        case empty
        case withData
    }

    private var currentGoalViewState: GoalViewState = .notSetUp
    private var currentEntriesViewState: EntriesViewState = .notSetUp

        //MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var currentGoalView: UIView?
    private let titleView = UIView()
    private let cardView = CardView()
    private var greetingTitle = UILabel()
    private var nameTitle = UILabel()
    private var avatarImage = UIImageView()
    private let recentActivityStackView = UIStackView()
    private let lastEntriesContainerView = UIView()
    private var lastEntriesCollectionView: UICollectionView?
    private var emptyDataView: UIView?

    private var recentActivityTopConstraint: NSLayoutConstraint?
    private var goalViewConstraints: [NSLayoutConstraint] = []

        //MARK: - Constants
    private enum Constants {
        static let defaultPadding: CGFloat = 24
        static let cardHeight: CGFloat = 200
        static let goalViewHeight: CGFloat = 200
        static let emptyViewHeight: CGFloat = 300
        static let topViewHeight: CGFloat = 48

        enum SubViewsLayerParams{
            static let cornerRadius: CGFloat = 20
            static let shadowRadius: CGFloat = 12
            static let shadowOpacity: CGFloat = 0.2
            static let shadowOffset: CGSize = CGSize(width: 0, height: 10)
        }

        enum AvatarImageView {
            static let height: CGFloat = 45
            static let width: CGFloat = 45
            static let cornerRadius: CGFloat = 22.5
        }
        enum NotificationsButton {
            static let height: CGFloat = 36
            static let width: CGFloat = 36
        }

    }

        //MARK: - Initialization / Deinitialization
    init(viewModel: any MainViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "MainViewController inited")
        Logger.ui.debug("\(logMessage, privacy: .public)")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "MainViewController deinited")
        Logger.ui.debug("\(logMessage, privacy: .public)")
    }

        //MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        Task {
            await viewModel.loadData()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = cardView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = cardView.bounds
        }
    }

        // MARK: - Binding
    private func bindViewModel() {
        viewModel.viewStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                    case .ready, .loading:
                        break
                    case .loaded(let data):
                        self?.currentData = data
                        self?.updateUI(with: data)
                    case .error(let message):
                        self?.showAlert(title: "Error ❌", message: message)
                    case .success(let message):
                        self?.showAlert(title: "Successfully ✅", message: message)
                }
            }
            .store(in: &cancellables)
    }

        // MARK: - Main Update Logic (Только рисование!)

    private func updateUI(with data: MainViewData) {
        updateGreeting(data.greeting)
        updateCard(data.card)
        updateGoalView(data.goalView)
        updateEntriesView(data.entriesView)
        updateRecentActivitySection(visible: data.shouldShowRecentActivitySection)
    }

    private func updateGreeting(_ greeting: GreetingViewData) {
        greetingTitle.text = greeting.timeOfDay
        nameTitle.text = greeting.userName
        avatarImage.image = UIImage(named: greeting.avatarImageName)
    }

    private func updateCard(_ card: CardViewData) {
        cardView.updateData(
            total: card.totalRaw,
            paid: card.paidRaw,
            pending: card.pendingRaw
        )
    }

    private func updateGoalView(_ goalViewType: GoalViewType) {
        switch goalViewType {
            case .empty:
                if currentGoalViewState != .empty {
                    setupEmptyGoalView()
                    currentGoalViewState = .empty
                }
            case .withStats(let stats):
                if currentGoalViewState != .withData {
                    setupGoalAndStatsCardView()
                    currentGoalViewState = .withData
                }
                updateGoalStatsView(with: stats)
        }
    }

    private func updateGoalStatsView(with stats: GoalStatsViewData) {
        guard let goalView = currentGoalView as? GoalAndStatsCardView else { return }
        goalView.setGoalValues(
            current: stats.currentRaw,
            goal: stats.goalRaw
        )
        goalView.setStatsValues(
            newValues: stats.topSources.map { ($0.name, $0.amountRaw) }
        )
        goalView.actionForViewBtnStats = { [weak self] in
            self?.tabBarController?.selectedIndex = 1
        }
    }

    private func updateEntriesView(_ entriesViewType: EntriesViewType) {
        switch entriesViewType {
            case .empty(let emptyState):
                if currentEntriesViewState != .empty {
                    clearEntriesContainer()
                    setupEmptyDataView(with: emptyState)
                    currentEntriesViewState = .empty
                }
            case .entries:
                if currentEntriesViewState != .withData {
                    clearEntriesContainer()
                    setupCollectionView()
                    currentEntriesViewState = .withData
                } else {
                    lastEntriesCollectionView?.reloadData()
                    updateCollectionHeight()
                }
        }
    }

    private func updateRecentActivitySection(visible: Bool) {
        recentActivityStackView.isHidden = !visible
    }

    private func clearEntriesContainer() {
        lastEntriesContainerView.subviews.forEach { $0.removeFromSuperview() }
        lastEntriesCollectionView = nil
        emptyDataView = nil
    }

        // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = DSColors.appBackground
        navigationController?.navigationBar.prefersLargeTitles = false

        setupScrollView()
        setupContentView()
        setupTopView()
        setupCardView()
        setupRecentActivityLabel()
        setupLastEntriesContainerView()
        setupConstraints()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        view.addSubview(scrollView)
    }

    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }

    private func setupTopView() {
        titleView.backgroundColor = .clear
        titleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleView)

        greetingTitle.font = .systemFont(ofSize: 15, weight: .regular)
        greetingTitle.textColor = DSColors.appTextPrimary
        greetingTitle.backgroundColor = .clear

        nameTitle.font = .systemFont(ofSize: 27, weight: .bold)
        nameTitle.textColor = DSColors.appTextPrimary
        nameTitle.backgroundColor = .clear

        avatarImage = makeAvatarImageView()
        let notificationButton = makeNotificationButton()

        [avatarImage, notificationButton, greetingTitle, nameTitle].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            titleView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            avatarImage.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            avatarImage.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            avatarImage.widthAnchor.constraint(equalToConstant: Constants.AvatarImageView.width),
            avatarImage.heightAnchor.constraint(equalToConstant: Constants.AvatarImageView.height),

            greetingTitle.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 12),
            greetingTitle.topAnchor.constraint(equalTo: titleView.topAnchor),

            nameTitle.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 12),
            nameTitle.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),

            notificationButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            notificationButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            notificationButton.widthAnchor.constraint(equalToConstant: Constants.NotificationsButton.width),
            notificationButton.heightAnchor.constraint(equalToConstant: Constants.NotificationsButton.height)
        ])
    }

    private func makeAvatarImageView() -> UIImageView {
        let avatar = UIImageView()
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = Constants.AvatarImageView.cornerRadius
        avatar.clipsToBounds = true
        return avatar
    }

    private func makeNotificationButton() -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)

        let normalImage = UIImage(systemName: "bell.badge", withConfiguration: config)?
            .withTintColor(.designBlack, renderingMode: .alwaysOriginal)
        let highlightedImage = UIImage(systemName: "bell.badge.fill", withConfiguration: config)?
            .withTintColor(DSColors.appPrimary, renderingMode: .alwaysOriginal)

        button.setImage(normalImage, for: .normal)
        button.setImage(highlightedImage, for: .highlighted)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(openNotifications), for: .touchUpInside)
        button.projectAnimationForButtons()
        return button
    }

    private func setupCardView() {
        cardView.layer.cornerRadius = Constants.SubViewsLayerParams.cornerRadius
        cardView.layer.shadowColor = DSColors.shadowColor.cgColor
        cardView.layer.shadowOpacity = Float(Constants.SubViewsLayerParams.shadowOpacity)
        cardView.layer.shadowOffset = Constants.SubViewsLayerParams.shadowOffset
        cardView.layer.shadowRadius = Constants.SubViewsLayerParams.shadowRadius
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
    }

    private func setupRecentActivityLabel() {
        let recentLabel = UILabel()
        recentLabel.text = "Recent Activity"
        recentLabel.textColor = DSColors.appTextPrimary
        recentLabel.font = .systemFont(ofSize: 24, weight: .semibold)

        let seeAllButton = makeSeeAllButton()

        recentActivityStackView.addArrangedSubview(recentLabel)
        recentActivityStackView.addArrangedSubview(seeAllButton)
        recentActivityStackView.axis = .horizontal
        recentActivityStackView.alignment = .fill
        recentActivityStackView.distribution = .equalSpacing
        recentActivityStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(recentActivityStackView)
    }

    private func makeSeeAllButton() -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = "See All"

        let button = UIButton()
        button.configuration = config
        button.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration
            switch button.state {
                case .normal:
                    updatedConfig?.baseForegroundColor = DSColors.appTextSecondary
                case .highlighted:
                    updatedConfig?.baseForegroundColor = DSColors.appPrimary
                default:
                    updatedConfig?.baseForegroundColor = DSColors.appTextSecondary
            }
            button.configuration = updatedConfig
        }
        button.addTarget(self, action: #selector(actionSeeAll), for: .touchUpInside)
        return button
    }

    private func setupLastEntriesContainerView() {
        lastEntriesContainerView.backgroundColor = .clear
        lastEntriesContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lastEntriesContainerView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.defaultPadding),
            titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.defaultPadding),
            titleView.heightAnchor.constraint(equalToConstant: Constants.topViewHeight),

            cardView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.defaultPadding),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.defaultPadding),
            cardView.heightAnchor.constraint(equalToConstant: Constants.cardHeight),

            recentActivityStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 27),
            recentActivityStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            lastEntriesContainerView.topAnchor.constraint(equalTo: recentActivityStackView.bottomAnchor, constant: 20),
            lastEntriesContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.defaultPadding),
            lastEntriesContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.defaultPadding),
            lastEntriesContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

        // MARK: - Goal View Management

    private func setGoalView(_ newView: UIView) {
        if let constraint = recentActivityTopConstraint {
            constraint.isActive = false
            recentActivityTopConstraint = nil
        }

        NSLayoutConstraint.deactivate(goalViewConstraints)
        goalViewConstraints.removeAll()

        currentGoalView?.removeFromSuperview()

        currentGoalView = newView
        newView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(newView)

        goalViewConstraints = [
            newView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20),
            newView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.defaultPadding),
            newView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.defaultPadding),
            newView.heightAnchor.constraint(equalToConstant: Constants.goalViewHeight)
        ]
        NSLayoutConstraint.activate(goalViewConstraints)

        updateRecentActivityConstraint()
    }

    private func updateRecentActivityConstraint() {
        if let oldConstraint = recentActivityTopConstraint {
            oldConstraint.isActive = false
            recentActivityTopConstraint = nil
        }

        guard let goalView = currentGoalView, goalView.superview != nil else {
            return
        }

        let newConstraint = recentActivityStackView.topAnchor.constraint(
            equalTo: goalView.bottomAnchor,
            constant: 20
        )
        newConstraint.isActive = true
        recentActivityTopConstraint = newConstraint

        contentView.setNeedsLayout()
    }

    private func setupEmptyGoalView() {
        let emptyGoalView = EmptyGoalView()
        emptyGoalView.backgroundColor = DSColors.MonthlyGoalCardColors.background
        emptyGoalView.layer.cornerRadius = Constants.SubViewsLayerParams.cornerRadius
        emptyGoalView.layer.shadowColor = DSColors.shadowColor.cgColor
        emptyGoalView.layer.shadowOpacity = Float(Constants.SubViewsLayerParams.shadowOpacity)
        emptyGoalView.layer.shadowOffset = Constants.SubViewsLayerParams.shadowOffset
        emptyGoalView.layer.shadowRadius = Constants.SubViewsLayerParams.shadowRadius
        setGoalView(emptyGoalView)
    }

    private func setupGoalAndStatsCardView() {
        let goalAndStatsCard = GoalAndStatsCardView()
        goalAndStatsCard.backgroundColor = DSColors.MonthlyGoalCardColors.background
        goalAndStatsCard.layer.cornerRadius = Constants.SubViewsLayerParams.cornerRadius
        goalAndStatsCard.layer.shadowColor = DSColors.shadowColor.cgColor
        goalAndStatsCard.layer.shadowOpacity = Float(Constants.SubViewsLayerParams.shadowOpacity)
        goalAndStatsCard.layer.shadowOffset = Constants.SubViewsLayerParams.shadowOffset
        goalAndStatsCard.layer.shadowRadius = Constants.SubViewsLayerParams.shadowRadius
        setGoalView(goalAndStatsCard)
    }

        // MARK: - Entries View Management

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(IncomeCollectionViewCell.self,
                                forCellWithReuseIdentifier: IncomeCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.animateSlideInFromRight(translationX: view.bounds.maxX, options: [.transitionCrossDissolve])
        lastEntriesContainerView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: lastEntriesContainerView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: lastEntriesContainerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: lastEntriesContainerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: lastEntriesContainerView.bottomAnchor)
        ])

        lastEntriesCollectionView = collectionView
        collectionView.reloadData()
        updateCollectionHeight()
    }

    private func setupEmptyDataView(with emptyState: EmptyStateViewData) {
        let emptyView = EmptyDataView(
            title: emptyState.title,
            description: emptyState.description
        )
        emptyView.backgroundColor = .clear
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        lastEntriesContainerView.addSubview(emptyView)

        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: lastEntriesContainerView.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: lastEntriesContainerView.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: lastEntriesContainerView.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: lastEntriesContainerView.bottomAnchor),
            emptyView.heightAnchor.constraint(equalToConstant: Constants.emptyViewHeight)
        ])

        emptyDataView = emptyView
    }

    private func updateCollectionHeight() {
        guard let collectionView = lastEntriesCollectionView else { return }

        collectionView.layoutIfNeeded()
        let newHeight = collectionView.contentSize.height

        if let oldConstraint = collectionView.constraints.first(where: { $0.firstAttribute == .height }) {
            collectionView.removeConstraint(oldConstraint)
        }

        collectionView.heightAnchor.constraint(equalToConstant: newHeight + 10).isActive = true

        UIView.animate(withDuration: 0.3) {
            self.lastEntriesContainerView.layoutIfNeeded()
        }
    }

        // MARK: - Actions

    @objc private func openNotifications() {
        print("Написать тело функции просмотра уведомлений")
    }

    @objc private func actionSeeAll() {
        tabBarController?.selectedIndex = 3
    }

    private func showAlert(title: String, message: String) {
        let customAlert = CustomAlert(title: title, message: message)
        let okAction = AlertAction(title: "OK", style: .baseDefault) { [weak self] in
            self?.dismiss(animated: true)
        }
        customAlert.addAction(okAction)
        customAlert.showAlert(from: self)
    }
}

    // MARK: - UICollectionView DataSource & Delegate

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = currentData,
              case .entries(let entries) = data.entriesView else {
            return 0
        }
        return entries.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: IncomeCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! IncomeCollectionViewCell

        guard let data = currentData,
              case .entries(let entries) = data.entriesView,
              indexPath.item < entries.count else {
            return cell
        }

        let entry = entries[indexPath.item]

        cell.configure(with: entry)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        if cell.layer.animation(forKey: "wobbleAnimation") != nil {
            cell.layer.removeAnimation(forKey: "wobbleAnimation")
        } else {
            let animation = makeShakeAnimation()
            cell.layer.add(animation, forKey: "wobbleAnimation")
        }

//        viewModel.didSelectEntry(at: indexPath.item)
    }

    private func makeShakeAnimation() -> CAAnimation {
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.values = [0, 10, -10, 0]
        shake.duration = 0.1
        shake.repeatCount = 2
        return shake
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 10
        let height: CGFloat = 100
        return CGSize(width: width, height: height)
    }
}

    // MARK: - UIScrollViewDelegate

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }

        let currentOffset = scrollView.contentOffset.y
        let difference = currentOffset - lastContentOffset
        let threshold: CGFloat = 50

        if abs(difference) > 5 {
            if difference > 0 && currentOffset > threshold {
                animateTabBar(hide: true)
            } else if difference < 0 {
                animateTabBar(hide: false)
            }
        }

        lastContentOffset = currentOffset
    }

    private func animateTabBar(hide: Bool) {
        guard let tabBarController = tabBarController else { return }

        let tabBar = tabBarController.tabBar
        let hiddenY = view.frame.height + 30
        let visibleY = view.frame.height - tabBar.frame.height

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                tabBar.frame.origin.y = hide ? hiddenY : visibleY
            }
        )
    }
}

////
////  MainViewController.swift
////  EarnLog
////
////  Created by M3 pro on 13/07/2025.
////
//import Foundation
//import UIKit
//import Combine
//import OSLog
//
//final class MainViewController: UIViewController {
//
//        // MARK: - Private Properties
//    private let viewModel: any MainViewModelProtocol
//    private var cancellables: Set<AnyCancellable> = []
//    private var lastContentOffset: CGFloat = 0
//    private var currentData: MainViewData?
//
//        // MARK: - State Properties
//    private enum GoalViewState {
//        case notSetUp
//        case empty
//        case withData
//    }
//
//    private enum EntriesViewState {
//        case notSetUp
//        case empty
//        case withData
//    }
//
//    private var currentGoalViewState: GoalViewState = .notSetUp
//    private var currentEntriesViewState: EntriesViewState = .notSetUp
//
//        //MARK: - UI Components
//    private let scrollView = UIScrollView()
//    private let contentView = UIView()
//    private var currentGoalView: UIView?
//    private let titleView = UIView()
//    private let cardView = CardView()
//    private var greetingTitle = UILabel()
//    private let recentActivityStackView = UIStackView()
//    private let lastEntriesContainerView = UIView()
//    private var lastEntriesCollectionView: UICollectionView?
//    private var emptyDataView: UIView?
//
//    private var recentActivityTopConstraint: NSLayoutConstraint?
//    private var goalViewConstraints: [NSLayoutConstraint] = []
//
//        //MARK: - Constants
//    private enum Constants {
//        static let defaultPadding: CGFloat = 24
//        static let cardHeight: CGFloat = 200
//        static let goalViewHeight: CGFloat = 200
//        static let emptyViewHeight: CGFloat = 300
//        static let topViewHeight: CGFloat = 48
//    }
//
//        //MARK: - Initialization / Deinitialization
//    init(viewModel: any MainViewModelProtocol) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//
//        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "MainViewController inited")
//        Logger.ui.debug("\(logMessage, privacy: .public)")
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    deinit {
//        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "MainViewController deinited")
//        Logger.ui.debug("\(logMessage, privacy: .public)")
//    }
//
//        //MARK: - LifeCycles
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        bindViewModel()
//        Task {
//            await viewModel.loadData()
//        }
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if let gradientLayer = cardView.layer.sublayers?.first as? CAGradientLayer {
//            gradientLayer.frame = cardView.bounds
//        }
//    }
//
//        // MARK: - Binding
//    private func bindViewModel() {
//        viewModel.viewStatePublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] state in
//                switch state {
//                    case .ready, .loading:
//                        break
//                    case .loaded(let data):
//                        self?.currentData = data
//                        self?.updateUI(with: data)
//                    case .error(let message):
//                        self?.showAlert(title: "Error ❌", message: message)
//                    case .success(let message):
//                        self?.showAlert(title: "Successfully ✅", message: message)
//                }
//            }
//            .store(in: &cancellables)
//    }
//
//        // MARK: - Main Update Logic
//    private func updateUI(with data: MainViewData) {
//            // 1. Всегда обновляем простые элементы
//        updateStaticElements(with: data)
//
//            // 2. Обновляем GoalView в зависимости от состояния
//        updateGoalViewIfNeeded(with: data)
//
//            // 3. Обновляем EntriesView в зависимости от состояния
//        updateEntriesViewIfNeeded(with: data)
//    }
//
//    private func updateStaticElements(with data: MainViewData) {
//        greetingTitle.text = data.lastTimeOfDay
//
//        cardView.updateData(
//            total: data.cardData.totalVolume,
//            paid: data.cardData.paidVolume,
//            pending: data.cardData.unpaidVolume
//        )
//    }
//
//    private func updateGoalViewIfNeeded(with data: MainViewData) {
//        let shouldShowEmpty = data.setEmptyGoal
//        let targetState: GoalViewState = shouldShowEmpty ? .empty : .withData
//
//            // Если состояние не изменилось, просто обновляем данные
//        if currentGoalViewState == targetState {
//            if case .withData = targetState {
//                updateGoalViewData(with: data)
//            }
//            return
//        }
//
//            // Иначе пересоздаем view
//        if shouldShowEmpty {
//            setupEmptyGoalView()
//            currentGoalViewState = .empty
//        } else {
//            setupGoalAndStatsCardView()
//            updateGoalViewData(with: data)
//            currentGoalViewState = .withData
//        }
//    }
//
//    private func updateEntriesViewIfNeeded(with data: MainViewData) {
//        let shouldShowEmpty = data.setEmptyEntries
//        let targetState: EntriesViewState = shouldShowEmpty ? .empty : .withData
//
//            // Если состояние не изменилось, просто обновляем данные
//        if currentEntriesViewState == targetState {
//            if case .withData = targetState {
//                lastEntriesCollectionView?.reloadData()
//                updateCollectionHeight()
//            }
//            return
//        }
//
//            // Иначе пересоздаем view
//        clearEntriesContainer()
//        if shouldShowEmpty {
//            setupEmptyDataView()
//            currentEntriesViewState = .empty
//        } else {
//            setupCollectionView()
//            currentEntriesViewState = .withData
//        }
//    }
//
//    private func updateGoalViewData(with data: MainViewData) {
//        guard let goalView = currentGoalView as? GoalAndStatsCardView else { return }
//        goalView.setGoalValues(
//            current: data.monthlyGoalStats.total,
//            goal: data.monthlyGoalStats.goal
//        )
//        goalView.setStatsValues(newValues: data.lastMonthStats)
//    }
//
//    private func clearEntriesContainer() {
//        lastEntriesContainerView.subviews.forEach { $0.removeFromSuperview() }
//        lastEntriesCollectionView = nil
//        emptyDataView = nil
//    }
//
//        // MARK: - Setup UI
//    private func setupUI() {
//        view.backgroundColor = DSColors.appBackground
//        navigationController?.navigationBar.prefersLargeTitles = false
//
//        setupScrollView()
//        setupContentView()
//        setupTopView()
//        setupCardView()
//        setupRecentActivityLabel()
//        setupLastEntriesContainerView()
//        setupConstraints()
//    }
//
//    private func setupScrollView() {
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.alwaysBounceVertical = true
//        scrollView.backgroundColor = .clear
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.delegate = self
//        view.addSubview(scrollView)
//    }
//
//    private func setupContentView() {
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(contentView)
//    }
//
//    private func setupTopView() {
//        titleView.backgroundColor = .clear
//        titleView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(titleView)
//
//        greetingTitle.font = .systemFont(ofSize: 15, weight: .regular)
//        greetingTitle.textColor = DSColors.appTextPrimary
//        greetingTitle.backgroundColor = .clear
//
//        let avatarImage = makeAvatarImageView()
//        let nameTitle = makeNameTitleLabel()
//        let notificationButton = makeNotificationButton()
//
//        [avatarImage, notificationButton, greetingTitle, nameTitle].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            titleView.addSubview($0)
//        }
//
//        NSLayoutConstraint.activate([
//            avatarImage.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
//            avatarImage.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
//            avatarImage.widthAnchor.constraint(equalToConstant: 45),
//            avatarImage.heightAnchor.constraint(equalToConstant: 45),
//
//            greetingTitle.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 12),
//            greetingTitle.topAnchor.constraint(equalTo: titleView.topAnchor),
//
//            nameTitle.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 12),
//            nameTitle.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
//
//            notificationButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
//            notificationButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
//            notificationButton.widthAnchor.constraint(equalToConstant: 36),
//            notificationButton.heightAnchor.constraint(equalToConstant: 36)
//        ])
//    }
//
//    private func makeAvatarImageView() -> UIImageView {
//        let avatar = UIImageView(image: UIImage(named: "avatar"))
//        avatar.contentMode = .scaleAspectFill
//        avatar.layer.cornerRadius = 22.5
//        avatar.clipsToBounds = true
//        return avatar
//    }
//
//    private func makeNameTitleLabel() -> UILabel {
//        let title = UILabel()
//        title.text = "Anna Smith" // FIXME: Привязать к имени юзера
//        title.font = .systemFont(ofSize: 27, weight: .bold)
//        title.textColor = DSColors.appTextPrimary
//        title.backgroundColor = .clear
//        return title
//    }
//
//    private func makeNotificationButton() -> UIButton {
//        let button = UIButton(type: .system)
//        let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
//
//        let normalImage = UIImage(systemName: "bell.badge", withConfiguration: config)?
//            .withTintColor(DSColors.appTextPrimary, renderingMode: .alwaysOriginal)
//        let highlightedImage = UIImage(systemName: "bell.badge.fill", withConfiguration: config)?
//            .withTintColor(DSColors.appPrimary, renderingMode: .alwaysOriginal)
//
//        button.setImage(normalImage, for: .normal)
//        button.setImage(highlightedImage, for: .highlighted)
//        button.backgroundColor = .clear
//        button.addTarget(self, action: #selector(openNotifications), for: .touchUpInside)
//        button.projectAnimationForButtons()
//        return button
//    }
//
//    private func setupCardView() {
//        cardView.layer.cornerRadius = 20
//        cardView.layer.shadowColor = DSColors.shadowColor.cgColor
//        cardView.layer.shadowOpacity = 0.2
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
//        cardView.layer.shadowRadius = 12
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(cardView)
//    }
//
//    private func setupRecentActivityLabel() {
//        let recentLabel = UILabel()
//        recentLabel.text = "Recent Activity"
//        recentLabel.textColor = DSColors.appTextPrimary
//        recentLabel.font = .systemFont(ofSize: 24, weight: .semibold)
//
//        let seeAllButton = makeSeeAllButton()
//
//        recentActivityStackView.addArrangedSubview(recentLabel)
//        recentActivityStackView.addArrangedSubview(seeAllButton)
//        recentActivityStackView.axis = .horizontal
//        recentActivityStackView.alignment = .fill
//        recentActivityStackView.distribution = .equalSpacing
//        recentActivityStackView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(recentActivityStackView)
//    }
//
//    private func makeSeeAllButton() -> UIButton {
//        var config = UIButton.Configuration.plain()
//        config.title = "See All"
//
//        let button = UIButton()
//        button.configuration = config
//        button.configurationUpdateHandler = { button in
//            var updatedConfig = button.configuration
//            switch button.state {
//                case .normal:
//                    updatedConfig?.baseForegroundColor = DSColors.appTextSecondary
//                case .highlighted:
//                    updatedConfig?.baseForegroundColor = DSColors.appPrimary
//                default:
//                    updatedConfig?.baseForegroundColor = DSColors.appTextSecondary
//            }
//            button.configuration = updatedConfig
//        }
//        button.addTarget(self, action: #selector(actionSeeAll), for: .touchUpInside)
//        return button
//    }
//
//    private func setupLastEntriesContainerView() {
//        lastEntriesContainerView.backgroundColor = .clear
//        lastEntriesContainerView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(lastEntriesContainerView)
//    }
//
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//
//            titleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.defaultPadding),
//            titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.defaultPadding),
//            titleView.heightAnchor.constraint(equalToConstant: Constants.topViewHeight),
//
//            cardView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 20),
//            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.defaultPadding),
//            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.defaultPadding),
//            cardView.heightAnchor.constraint(equalToConstant: Constants.cardHeight),
//
//            recentActivityStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 27),
//            recentActivityStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//
//            lastEntriesContainerView.topAnchor.constraint(equalTo: recentActivityStackView.bottomAnchor, constant: 20),
//            lastEntriesContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.defaultPadding),
//            lastEntriesContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.defaultPadding),
//            lastEntriesContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//        ])
//    }
//
//        // MARK: - Goal View Management
//    private func setGoalView(_ newView: UIView) {
//            // 1. Деактивируем constraint с recentActivityStackView
//        if let constraint = recentActivityTopConstraint {
//            constraint.isActive = false
//            recentActivityTopConstraint = nil
//        }
//
//            // 2. Деактивируем constraints старого goalView
//        NSLayoutConstraint.deactivate(goalViewConstraints)
//        goalViewConstraints.removeAll()
//
//            // 3. Удаляем старое view
//        currentGoalView?.removeFromSuperview()
//
//            // 4. Устанавливаем новое view
//        currentGoalView = newView
//        newView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(newView)
//
//            // 5. Создаем constraints для нового goalView
//        goalViewConstraints = [
//            newView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20),
//            newView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.defaultPadding),
//            newView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.defaultPadding),
//            newView.heightAnchor.constraint(equalToConstant: Constants.goalViewHeight)
//        ]
//        NSLayoutConstraint.activate(goalViewConstraints)
//
//            // 6. Обновляем constraint с recentActivityStackView
//        updateRecentActivityConstraint()
//    }
//
//    private func updateRecentActivityConstraint() {
//        if let oldConstraint = recentActivityTopConstraint {
//            oldConstraint.isActive = false
//            recentActivityTopConstraint = nil
//        }
//
//        guard let goalView = currentGoalView, goalView.superview != nil else {
//            return
//        }
//
//        let newConstraint = recentActivityStackView.topAnchor.constraint(
//            equalTo: goalView.bottomAnchor,
//            constant: 20
//        )
//        newConstraint.isActive = true
//        recentActivityTopConstraint = newConstraint
//
//        contentView.setNeedsLayout()
//    }
//
//    private func setupEmptyGoalView() {
//        let emptyGoalView = EmptyGoalView()
//        emptyGoalView.backgroundColor = DSColors.MonthlyGoalCardColors.background
//        emptyGoalView.layer.cornerRadius = 20
//        emptyGoalView.layer.shadowColor = DSColors.shadowColor.cgColor
//        emptyGoalView.layer.shadowOpacity = 0.4
//        emptyGoalView.layer.shadowOffset = CGSize(width: 0, height: 10)
//        emptyGoalView.layer.shadowRadius = 12
//        setGoalView(emptyGoalView)
//    }
//
//    private func setupGoalAndStatsCardView() {
//        let goalAndStatsCard = GoalAndStatsCardView()
//        goalAndStatsCard.backgroundColor = DSColors.MonthlyGoalCardColors.background
//        goalAndStatsCard.layer.cornerRadius = 20
//        goalAndStatsCard.layer.shadowColor = DSColors.shadowColor.cgColor
//        goalAndStatsCard.layer.shadowOpacity = 0.2
//        goalAndStatsCard.layer.shadowOffset = CGSize(width: 0, height: 10)
//        goalAndStatsCard.layer.shadowRadius = 12
//        goalAndStatsCard.actionForViewBtnStats = { [weak self] in
//            self?.tabBarController?.selectedIndex = 1
//        }
//        setGoalView(goalAndStatsCard)
//    }
//
//        // MARK: - Entries View Management
//    private func setupCollectionView() {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 20
//        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
//
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.register(IncomeCollectionViewCell.self,
//                                forCellWithReuseIdentifier: IncomeCollectionViewCell.reuseIdentifier)
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.backgroundColor = .clear
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.isScrollEnabled = false
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.animateSlideInFromRight(translationX: view.bounds.maxX, options: [.transitionCrossDissolve])
//        lastEntriesContainerView.addSubview(collectionView)
//
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: lastEntriesContainerView.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: lastEntriesContainerView.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: lastEntriesContainerView.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: lastEntriesContainerView.bottomAnchor)
//        ])
//
//        lastEntriesCollectionView = collectionView
//        collectionView.reloadData()
//        updateCollectionHeight()
//    }
//
//    private func setupEmptyDataView() {
//        let emptyView = EmptyDataView(
//            title: "No Income Resourced Added Yet",
//            description: "Click \"Add New Income\" Button To Start Tracking"
//        )
//        emptyView.backgroundColor = .clear
//        emptyView.translatesAutoresizingMaskIntoConstraints = false
//        lastEntriesContainerView.addSubview(emptyView)
//
//        NSLayoutConstraint.activate([
//            emptyView.topAnchor.constraint(equalTo: lastEntriesContainerView.topAnchor),
//            emptyView.leadingAnchor.constraint(equalTo: lastEntriesContainerView.leadingAnchor),
//            emptyView.trailingAnchor.constraint(equalTo: lastEntriesContainerView.trailingAnchor),
//            emptyView.bottomAnchor.constraint(equalTo: lastEntriesContainerView.bottomAnchor),
//            emptyView.heightAnchor.constraint(equalToConstant: Constants.emptyViewHeight)
//        ])
//
//        emptyDataView = emptyView
//    }
//
//    private func updateCollectionHeight() {
//        guard let collectionView = lastEntriesCollectionView else { return }
//
//        collectionView.layoutIfNeeded()
//        let newHeight = collectionView.contentSize.height
//
//        if let oldConstraint = collectionView.constraints.first(where: { $0.firstAttribute == .height }) {
//            collectionView.removeConstraint(oldConstraint)
//        }
//
//        collectionView.heightAnchor.constraint(equalToConstant: newHeight + 10).isActive = true
//
//        UIView.animate(withDuration: 0.3) {
//            self.lastEntriesContainerView.layoutIfNeeded()
//        }
//    }
//
//        // MARK: - Actions
//    @objc private func openNotifications() {
//        print("Написать тело функции просмотра уведомлений")
//    }
//
//    @objc private func actionSeeAll() {
//        tabBarController?.selectedIndex = 3
//    }
//
//    private func showAlert(title: String, message: String) {
//        let customAlert = CustomAlert(title: title, message: message)
//        let okAction = AlertAction(title: "OK", style: .baseDefault) { [weak self] in
//            self?.dismiss(animated: true)
//        }
//        customAlert.addAction(okAction)
//        customAlert.showAlert(from: self)
//    }
//}
//
//    // MARK: - UICollectionView DataSource & Delegate
//extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return currentData?.lastEntries.count ?? 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: IncomeCollectionViewCell.reuseIdentifier,
//            for: indexPath
//        ) as! IncomeCollectionViewCell
//
//        if let entries = currentData?.lastEntries,
//           indexPath.item < entries.count {
//            cell.configure(with: entries[indexPath.item])
//        }
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//
//        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
//
//        if cell.layer.animation(forKey: "wobbleAnimation") != nil {
//            cell.layer.removeAnimation(forKey: "wobbleAnimation")
//        } else {
//            let animation = makeShakeAnimation()
//            cell.layer.add(animation, forKey: "wobbleAnimation")
//        }
//    }
//
//    private func makeShakeAnimation() -> CAAnimation {
//        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
//        shake.values = [0, 10, -10, 0]
//        shake.duration = 0.1
//        shake.repeatCount = 2
//        return shake
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = collectionView.bounds.width - 10
//        let height: CGFloat = 100
//        return CGSize(width: width, height: height)
//    }
//}
//
//    // MARK: - UIScrollViewDelegate
//extension MainViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard scrollView == self.scrollView else { return }
//
//        let currentOffset = scrollView.contentOffset.y
//        let difference = currentOffset - lastContentOffset
//        let threshold: CGFloat = 50
//
//        if abs(difference) > 5 {
//            if difference > 0 && currentOffset > threshold {
//                animateTabBar(hide: true)
//            } else if difference < 0 {
//                animateTabBar(hide: false)
//            }
//        }
//
//        lastContentOffset = currentOffset
//    }
//
//    private func animateTabBar(hide: Bool) {
//        guard let tabBarController = tabBarController else { return }
//
//        let tabBar = tabBarController.tabBar
//        let hiddenY = view.frame.height + 30
//        let visibleY = view.frame.height - tabBar.frame.height
//
//        UIView.animate(
//            withDuration: 0.25,
//            delay: 0,
//            options: [.curveEaseInOut],
//            animations: {
//                tabBar.frame.origin.y = hide ? hiddenY : visibleY
//            }
//        )
//    }
//}

////
////  MainViewController.swift (VIEW в MVVM)
////  JobData
////
////  Created by M3 pro on 13/07/2025.
////
//import Foundation
//import UIKit
//import Combine
//import OSLog
//
//final class MainViewController: UIViewController {
//
//        // MARK: - Private Properties
//    private let viewModel: any MainViewModelProtocol
//    private var data: MainViewData? {
//        didSet {
//            reloadViewData()
//        }
//    }
//    private var cancellables: Set<AnyCancellable> = []
//    private var recentActivityTopConstraint: NSLayoutConstraint?
//    private var goalViewConstraints: [NSLayoutConstraint] = []
//    private var lastContentOffset: CGFloat = 0
//
//        //MARK: - UI Components
//    private let scrollView = UIScrollView()
//    private let contentView = UIView()
//    private var currentGoalView: UIView?
//    private let titleView = UIView()
//    private let cardView = CardView()
//    private var greetingTitle = UILabel()
//    private let recentActivityStackView = UIStackView()
//    private let lastEntriesContainerView = UIView()
//    private var lastEntriesCollectionView: UICollectionView?
//    private var emptyDataView: UIView?
//
//        //MARK: - Initialization / Deinitialization
//    init(viewModel: any MainViewModelProtocol) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//
//        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "MainViewController inited")
//        Logger.ui.debug("\(logMessage, privacy: .public)")
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    deinit {
//        let logMessage = Logger.loggerFormattedMessage(logLevel: .debug, "MainViewController deinited")
//        Logger.ui.debug("\(logMessage, privacy: .public)")
//    }
//
//        //MARK: - LifeCycles
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        Task {
//            await viewModel.loadData()
//        }
//        bindViewModel()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//            // Обновляем размер градиента под размер view
//        if let gradientLayer = cardView.layer.sublayers?.first as? CAGradientLayer {
//            gradientLayer.frame = cardView.bounds
//
//        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        updateLabels()
//    }
//
//    private func bindViewModel() {
//        viewModel.viewStatePublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] state in
//                switch state{
//                    case .ready: break
//                    case .loading: break
//                    case .loaded(let data):
//                        self?.data = data
//                    case .error(let message):
//                        self?.showAlert(title: "Error ❌", message: message)
//                    case .success(let message):
//                        self?.showAlert(title: "SuccessFully ✅", message: message)
//                }
//            }
//            .store(in: &cancellables)
//
//    }
//
//        // MARK: - Setup View components
//
//    private func setupUI() {
//        view.backgroundColor = DSColors.appBackground
//        navigationController?.navigationBar.prefersLargeTitles = false
////        navigationController?.navigationBar.barTintColor = DSColors.appBackground
////        navigationController?.navigationBar.isHidden = true
//            // Сначала создаем и добавляем все view в иерархию
//        setupScrollView()
//        setupContentView()
//        setupTopView()
//        setupCardView()
//        setupRecentActivityLabel()
//        setupLastEntriesContainerView()
//
//            // Теперь все view созданы и добавлены в иерархию
//            // Можно безопасно создавать constraints
//        setupConstraints()
//    }
//
//    private func setupTopView() {
//        titleView.backgroundColor = .clear
//        titleView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(titleView) // ✅ Добавляем в contentView, не в scrollView
//
////        greetingTitle.text = viewModel.lastTimeOfDay
//        greetingTitle.font = .systemFont(ofSize: 15, weight: .regular)
//        greetingTitle.textColor = DSColors.appTextPrimary
//        greetingTitle.backgroundColor = .clear
//
//
//        let avatarImage = {
//            let avatar = UIImageView(image: UIImage(named: "avatar"))
//            avatar.contentMode = .scaleAspectFill
//            avatar.layer.cornerRadius = 22.5
//            avatar.clipsToBounds = true
//            return avatar
//        }()
//
//        let nameTitle = {
//            let title = UILabel()
//                // FIXME: Привязать к имени юзера
//            title.text = "Anna Smith"
//            title.font = .systemFont(ofSize: 27, weight: .bold)
//            title.textColor = DSColors.appTextPrimary
//            title.backgroundColor = .clear
//            return title
//        }()
//            //FIXME: - Сделать изменения иконки в зависимости наличия непрочитанных уведомлений
//        let notificationButton = {
//            let button = UIButton(type: .system)
//            let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
//
//            let normalImage = UIImage(systemName: "bell.badge", withConfiguration: config)?
//                .withTintColor(DSColors.appTextPrimary, renderingMode: .alwaysOriginal)
//            let highlightedImage = UIImage(systemName: "bell.badge.fill", withConfiguration: config)?
//                .withTintColor(DSColors.appPrimary, renderingMode: .alwaysOriginal)
//
//            button.setImage(normalImage, for: .normal)
//            button.setImage(highlightedImage, for: .highlighted)
//            button.backgroundColor = .clear
//            button.addTarget(self, action: #selector(openNotifications), for: .touchUpInside)
//            button.projectAnimationForButtons()
//            return button
//        }()
//
//
//        let elements = [avatarImage, notificationButton, greetingTitle, nameTitle]
//        elements.forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            titleView.addSubview($0)
//        }
//
//        NSLayoutConstraint.activate([
//            // Avatar constraints
//            avatarImage.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
//            avatarImage.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
//            avatarImage.widthAnchor.constraint(equalToConstant: 45),
//            avatarImage.heightAnchor.constraint(equalToConstant: 45),
//
//            // Greeting title constraints
//            greetingTitle.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 12),
//            greetingTitle.topAnchor.constraint(equalTo: titleView.topAnchor),
//
//            // Name title constraints
//            nameTitle.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 12),
//            nameTitle.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
//
//            // Notification button constraints
//            notificationButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
//            notificationButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
//            notificationButton.widthAnchor.constraint(equalToConstant: 36),
//            notificationButton.heightAnchor.constraint(equalToConstant: 36)
//
//        ])
//    }
//
//    private func setupScrollView() {
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.alwaysBounceVertical = true
//        scrollView.backgroundColor = .clear
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.delegate = self
//        view.addSubview(scrollView)
//    }
//
//    private func setupContentView() {
//        contentView.translatesAutoresizingMaskIntoConstraints = false
////        contentView.backgroundColor = DSColors.appBackground
//        scrollView.addSubview(contentView)
//    }
//
//    private func setGoalView(_ newView: UIView) {
//            // ШАГ 1: Сначала деактивируем constraint, связывающий recentActivityStackView с текущим goalView
//            // Это критически важно сделать ДО удаления старого view
//        if let constraint = recentActivityTopConstraint {
//            constraint.isActive = false
//            recentActivityTopConstraint = nil
//        }
//
//            // ШАГ 2: Деактивируем constraints старого goalView
//        NSLayoutConstraint.deactivate(goalViewConstraints)
//        goalViewConstraints.removeAll()
//
//            // ШАГ 3: Удаляем старое view из иерархии
//        currentGoalView?.removeFromSuperview()
//
//            // ШАГ 4: Устанавливаем новое view как текущее
//        currentGoalView = newView
//
//            // ШАГ 5: Настраиваем новое view и добавляем его в иерархию
//        newView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(newView)
//
//            // ШАГ 6: Создаем и активируем constraints для нового goalView
//        goalViewConstraints = [
//            newView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20),
//            newView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
//            newView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
//            newView.heightAnchor.constraint(equalToConstant: 200)
//        ]
//        NSLayoutConstraint.activate(goalViewConstraints)
//
//            // ШАГ 7: Используем асинхронный вызов для создания constraint
//            // Это гарантирует что все view полностью встроены в иерархию перед созданием constraint
//            // Асинхронность дает системе время завершить layout цикл
//        DispatchQueue.main.async { [weak self] in
//            self?.updateRecentActivityConstraint()
//        }
//
//    }
//
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//
//            titleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
//            titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
//            titleView.heightAnchor.constraint(equalToConstant: 48),
//
//            cardView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 20),
//            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
//            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
//            cardView.heightAnchor.constraint(equalToConstant: 200),
//
//            // ВАЖНО: НЕ создаем здесь constraint для recentActivityStackView.topAnchor
//            // Он будет создан динамически в updateRecentActivityConstraint()
//            recentActivityStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 27),
//            recentActivityStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//
//            lastEntriesContainerView.topAnchor.constraint(equalTo: recentActivityStackView.bottomAnchor, constant: 20),
//            lastEntriesContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
//            lastEntriesContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
//            lastEntriesContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//
//        ])
//
//    }
//
//    private func setupCardView(){
////        cardView.backgroundColor = DSColors.appBackground
//        cardView.layer.cornerRadius = 20
//        cardView.layer.shadowColor = DSColors.shadowColor.cgColor
//        cardView.layer.shadowOpacity = 0.2
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
//        cardView.layer.shadowRadius = 12
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(cardView)
//    }
//
//    private func setupEmptyGoalView() {
//        print("setupEmptyGoalView")
//        let emptyGoalView = EmptyGoalView()
//        emptyGoalView.backgroundColor = DSColors.MonthlyGoalCardColors.background
//        emptyGoalView.layer.cornerRadius = 20
//        emptyGoalView.layer.shadowColor = DSColors.shadowColor.cgColor
//        emptyGoalView.layer.shadowOpacity = 0.4
//        emptyGoalView.layer.shadowOffset = CGSize(width: 0, height: 10)
//        emptyGoalView.layer.shadowRadius = 12
//        emptyGoalView.translatesAutoresizingMaskIntoConstraints = false
//        setGoalView(emptyGoalView)
//    }
//
//    private func setupGoalAndStatsCardView() {
//        let goalAndStatsCard = GoalAndStatsCardView()
//        goalAndStatsCard.backgroundColor = DSColors.MonthlyGoalCardColors.background
//        goalAndStatsCard.layer.cornerRadius = 20
//        goalAndStatsCard.layer.shadowColor = DSColors.shadowColor.cgColor
//        goalAndStatsCard.layer.shadowOpacity = 0.2
//        goalAndStatsCard.layer.shadowOffset = CGSize(width: 0, height: 10)
//        goalAndStatsCard.layer.shadowRadius = 12
//        goalAndStatsCard.translatesAutoresizingMaskIntoConstraints = false
//        goalAndStatsCard.actionForViewBtnStats = { [weak self] in
//            self?.tabBarController?.selectedIndex = 1
//        }
//
//        setGoalView(goalAndStatsCard)
//    }
//
//    private func setupRecentActivityLabel(){
//        let recentLabel = UILabel()
//        let seeAllButton = UIButton()
//        recentLabel.text = "Recent Activity"
//        recentLabel.textColor = DSColors.appTextPrimary
//        recentLabel.font = .systemFont(ofSize: 24, weight: .semibold)
//
//        var config = UIButton.Configuration.plain()
//        config.title = "See All"
//
//        seeAllButton.configuration = config
//        seeAllButton.configurationUpdateHandler = { button in
//            var updatedConfig = button.configuration
//            switch button.state {
//                case .normal:
//                    updatedConfig?.baseForegroundColor = DSColors.appTextSecondary
//                case .highlighted:
//                    updatedConfig?.baseForegroundColor = DSColors.appPrimary
//                default:
//                    updatedConfig?.baseForegroundColor = DSColors.appTextSecondary
//            }
//            button.configuration = updatedConfig
//        }
//        seeAllButton.addTarget(self, action: #selector(actionSeeAll), for: .touchUpInside)
//
//        recentActivityStackView.addArrangedSubview(recentLabel)
//        recentActivityStackView.addArrangedSubview(seeAllButton)
//        recentActivityStackView.axis = .horizontal
//        recentActivityStackView.alignment = .fill
//        recentActivityStackView.distribution = .equalSpacing
//        recentActivityStackView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(recentActivityStackView)
//    }
//
//    private func setupCollectionView() {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 20
//        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
//
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout )
//        collectionView.register(IncomeCollectionViewCell.self,
//                                forCellWithReuseIdentifier: IncomeCollectionViewCell.reuseIdentifier)
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.backgroundColor = .clear
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.isScrollEnabled = false
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.animateSlideInFromRight(translationX: view.bounds.maxX, options: [.transitionCrossDissolve])
//        lastEntriesContainerView.addSubview(collectionView)
//
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: lastEntriesContainerView.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: lastEntriesContainerView.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: lastEntriesContainerView.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: lastEntriesContainerView.bottomAnchor)
//        ])
//        lastEntriesCollectionView = collectionView
//        updateCollectionHeight()
//    }
//
//    private func setupEmptyDataView(){
//
//        let emptyView = EmptyDataView(title: "No Income Resourced Added Yet",
//                                      description: "Click “Add New Income” Button To Start Tracking")
//        emptyView.backgroundColor = .clear
//        emptyView.translatesAutoresizingMaskIntoConstraints = false
//        lastEntriesContainerView.addSubview(emptyView)
//        NSLayoutConstraint.activate([
//            emptyView.topAnchor.constraint(equalTo: lastEntriesContainerView.topAnchor),
//            emptyView.leadingAnchor.constraint(equalTo: lastEntriesContainerView.leadingAnchor),
//            emptyView.trailingAnchor.constraint(equalTo: lastEntriesContainerView.trailingAnchor),
//            emptyView.bottomAnchor.constraint(equalTo: lastEntriesContainerView.bottomAnchor),
//            emptyView.heightAnchor.constraint(equalToConstant: 300) // или нужная высота
//        ])
//        emptyDataView = emptyView
//    }
//
//    private func setupLastEntriesContainerView(){
//        lastEntriesContainerView.backgroundColor = .clear
//        lastEntriesContainerView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(lastEntriesContainerView)
//    }
//
//            //MARK: - Update container views
//
//    private func updateGoalViewContainer() {
//        guard let data = data else { return }
//
//        if data.setEmptyGoal {
//            guard currentGoalView == nil || currentGoalView is GoalAndStatsCardView else { return }
//            setupEmptyGoalView()
//        } else {
//            guard currentGoalView == nil || currentGoalView is EmptyGoalView else { return }
//            setupGoalAndStatsCardView()
//        }
//    }
//
//    private func updateLastEntriesContainer(){
//        lastEntriesContainerView.subviews.forEach { $0.removeFromSuperview() }
//        lastEntriesCollectionView = nil
//        emptyDataView = nil
//
//        guard let data = data else { return }
//
//        if data.setEmptyEntries {
//            setupEmptyDataView()
//        } else {
//            setupCollectionView()
//        }
//    }
//
//        //MARK: - Update views data
//
//    private func reloadViewData(){
//        guard let data = data else { return }
//
//        let emptyGoalViewSetuped = (currentGoalView as? GoalAndStatsCardView) != nil
//        print("emptyGoalViewSetuped: \(emptyGoalViewSetuped)")
//        let collectionViewSetuped = lastEntriesCollectionView != nil
//        print("collectionViewSetuped: \(collectionViewSetuped)")
//
//        updateLabels()
//        updateCardViewData()
//
//        if data.setEmptyGoal {
//            updateGoalViewContainer()
//        } else {
//            updateGoalViewData()
//        }
//
//        if data.setEmptyEntries {
//            updateLastEntriesContainer()
//        } else {
//            updateCollectionHeight()
//        }
//
//        if collectionViewSetuped {
//            updateCollectionHeight()
//        }
//
////        if goalViewSetuped, collectionViewSetuped {
////            print("!data.goalIsEmpty, goalViewSetuped, collectionViewSetuped")
////            updateGoalViewData()
////            updateCollectionHeight()
////        } else {
////            print("reloadViewData/else")
////            updateGoalViewContainer()
////                //            updateGoalViewData()
////            updateLastEntriesContainer()
////        }
//
//    }
//
//    private func updateCardViewData(){
//        guard let data = data else { return }
//        cardView.updateData(
//            total: data.cardData.totalVolume,
//            paid: data.cardData.paidVolume,
//            pending: data.cardData.unpaidVolume
//        )
//    }
//
//    private func updateGoalViewData(){
//        guard let goalView = currentGoalView as? GoalAndStatsCardView else { return }
//            // Обновляем только если view точно является GoalAndStatsCardView
//        goalView.setGoalValues(
//            current: data?.monthlyGoalStats.total ?? 0,
//            goal: data?.monthlyGoalStats.goal ?? 0
//        )
//        goalView.setStatsValues(newValues: data?.lastMonthStats ?? [])
//        goalView.actionForViewBtnStats = { [weak self] in
//            self?.tabBarController?.selectedIndex = 1
//        }
//    }
//
//        //MARK: - Update views data
//
//    private func updateLabels(){
//        greetingTitle.text = data?.lastTimeOfDay
//    }
//
//    private func updateRecentActivityConstraint() {
//            // КРИТИЧЕСКИ ВАЖНО: сначала деактивируем и удаляем старый constraint
//        if let oldConstraint = recentActivityTopConstraint {
//            oldConstraint.isActive = false
//            recentActivityTopConstraint = nil
//        }
//
//            // Создаем новый constraint только после того, как убедимся что goalView существует и добавлен в иерархию
//        guard let goalView = currentGoalView,
//              goalView.superview != nil else {
//            print("⚠️ Warning: Cannot create constraint - goalView is not in view hierarchy")
//            return
//        }
//
//            // Создаем и сразу активируем новый constraint
//        let newConstraint = recentActivityStackView.topAnchor.constraint(
//            equalTo: goalView.bottomAnchor,
//            constant: 20
//        )
//        newConstraint.isActive = true
//
//            // Сохраняем ссылку на новый constraint
//        recentActivityTopConstraint = newConstraint
//
//            // Форсируем обновление layout
//        contentView.setNeedsLayout()
//    }
//
//
////    private func updateGoalViewContainer() {
////        guard let data = data else { return }
////        let goalExists = data.monthlyGoalStats.goal > 0.0
////
////        if goalExists {
////                // Создаем GoalAndStatsCardView только если его еще нет или если текущее view - EmptyGoalView
////            if !(currentGoalView is GoalAndStatsCardView) {
////                setupGoalAndStatsCardView()
////            }
////        } else {
////                // Создаем EmptyGoalView только если его еще нет или если текущее view - GoalAndStatsCardView
////            if !(currentGoalView is EmptyGoalView) {
////                setupEmptyGoalView()
////            }
////        }
////    }
//
//
//
//    private func updateCollectionHeight() {
////        lastEntriesCollectionView?.reloadData()
//        lastEntriesCollectionView?.layoutIfNeeded()
//
//        let newHeight = lastEntriesCollectionView?.contentSize.height ?? 0
//
//        if let oldConstraint = lastEntriesCollectionView?.constraints.first(where: { $0.firstAttribute == .height }) {
//            lastEntriesCollectionView?.removeConstraint(oldConstraint)
//        }
//        lastEntriesCollectionView?.heightAnchor.constraint(equalToConstant: newHeight + 10).isActive = true
//
//        UIView.animate(withDuration: 0.3) {
//            self.lastEntriesContainerView.layoutIfNeeded()
//        }
//    }
//
//    private func showAlert(title: String, message: String) {
//        let customAlert = CustomAlert(title: title,
//                                      message: message)
//        let okAction = AlertAction(title: "OK", style: .baseDefault) { [weak self] in
//            self?.dismiss(animated: true)
//        }
//        customAlert.addAction(okAction)
//        customAlert.showAlert(from: self)
//    }
//
//
//
//
//
////    private func reloadViewData(){
////        guard let data = data else { return }
////
////        let goalViewSetuped = (currentGoalView as? GoalAndStatsCardView) != nil
////
////        updateLabels()
////        updateCardViewData()
//////        updateGoalViewData()
////
////        if data.monthlyGoalStats.goal != 0,
////           ((currentGoalView as? GoalAndStatsCardView) != nil),
////           lastEntriesCollectionView != nil {
////            updateGoalViewData()
////            updateCollectionHeight()
////        } else {
////            updateGoalViewContainer()
//////            updateGoalViewData()
////            updateLastEntriesContainer()
////        }
////
////    }
//
//            //MARK: Actions
//    @objc
//    private func openNotifications() {
//        print("Написать тело функции просмотра уведомлений")
//    }
//
//    @objc
//    private func actionSeeAll(){
//        tabBarController?.selectedIndex = 3
//    }
//
//}
//
//        // MARK: - UICollectionView DataSource & Delegate
//extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        guard let data = data else { return 0 }
//        let collectionViewEntries = data.lastEntries
//        return collectionViewEntries.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = lastEntriesCollectionView?.dequeueReusableCell(
//            withReuseIdentifier: IncomeCollectionViewCell.reuseIdentifier, for: indexPath
//        ) as! IncomeCollectionViewCell
//        guard let data = data else { return cell}
//        let collectionViewEntries = data.lastEntries
//        // Безопасный доступ к данным
//        if indexPath.item < collectionViewEntries.count {
//            let item = collectionViewEntries[indexPath.item]
//            cell.configure(with: item)
//        }
//        
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//        
//        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
//        
//        if cell.layer.animation(forKey: "wobbleAnimation") != nil {
//            cell.layer.removeAnimation(forKey: "wobbleAnimation")
//        } else {
//            let animation = drainAnimate()
//            cell.layer.add(animation, forKey: "wobbleAnimation")
//        }
//    }
//
//    private func drainAnimate() -> CAAnimation {
//        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
//        shake.values = [0, 10, -10, 0]
//        shake.duration = 0.1
//        shake.repeatCount = 2
//        return shake
//    }
//    
//        // MARK: - UICollectionViewDelegateFlowLayout
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = collectionView.bounds.width - 10 // отступы по 10 с каждой стороны
//        let height: CGFloat = 100 // высота как у TableView ячейки, можете настроить
//        return CGSize(width: width, height: height)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//
////        if let incomeCell = cell as? IncomeCollectionViewCell {
////            incomeCell.animate(delayMultiplier: indexPath.row)
////            
////        }
//    }
//
//}
//
//    // MARK: - UIScrollViewDelegate
//extension MainViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard scrollView == self.scrollView else { return }
//        let currentOffset = scrollView.contentOffset.y
//        let difference = currentOffset - lastContentOffset
//        let threshold: CGFloat = 50 // Минимальное расстояние для срабатывания
//        
//        if abs(difference) > 5 { // Избегаем мелких движений
//            if difference > 0 && currentOffset > threshold {
//                // Прокрутка вниз - скрываем
//                animateTabBar(hide: true)
//            } else if difference < 0 {
//                // Прокрутка вверх - показываем
//                animateTabBar(hide: false)
//            }
//        }
//        
//        lastContentOffset = currentOffset
//    }
//    
//    private func animateTabBar(hide: Bool) {
//        guard let tabBarController = tabBarController else { return }
//        
//        let tabBar = tabBarController.tabBar
////        let safeAreaBottom = view.safeAreaInsets.bottom
//        
//        let hiddenY = view.frame.height + 30
//        let visibleY = view.frame.height - tabBar.frame.height/* - safeAreaBottom*/
//        
//        UIView.animate(
//            withDuration: 0.25,
//            delay: 0,
//            options: [.curveEaseInOut],
//            animations: {
//                tabBar.frame.origin.y = hide ? hiddenY : visibleY
//            }
//        )
//    }
//}
