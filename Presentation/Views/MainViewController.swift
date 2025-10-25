//
//  MainViewController.swift (VIEW в MVVM)
//  JobData
//
//  Created by M3 pro on 13/07/2025.
//
import Foundation
import UIKit
import Combine

// MARK: - вариант для установки переворачивающиеся второй карточки -> goalAndStatsCard = GoalAndStatsCardView()
final class MainViewController: UIViewController, MemoryTrackable {
    
    // MARK: - Private Properties
    private let viewModel = AppDependencies.shared.mainViewModel
    private var data: MainViewData? {
        didSet { 
            reloadViewData()
        }
    }
    private var cancellables: Set<AnyCancellable> = []
    private var recentActivityTopConstraint: NSLayoutConstraint?
    private var goalViewConstraints: [NSLayoutConstraint] = []
    private var lastContentOffset: CGFloat = 0

    //MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var currentGoalView: UIView?
    private let titleView = UIView()
    private let cardView = CardView()
    private var greetingTitle = UILabel()
    private let recentActivityStackView = UIStackView()
    private let lastEntriesContainerView = UIView()
    private var lastEntriesCollectionView: UICollectionView?
    private var emptyDataView: UIView?

    
    init() {
        super.init(nibName: nil, bundle: nil)
        trackCreation()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()        
        Task {
            await viewModel.loadData()
        }
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state{
                    case .ready: break
                    case .loading: break
                    case .loaded(let data):
                        self?.data = data
                    case .error(let message):
                        self?.showAlert(title: "Error ❌", message: message)
                    case .success(let message):
                        self?.showAlert(title: "SuccessFully ✅", message: message)
                }
            }
            .store(in: &cancellables)

    }
    
    private func reloadViewData(){
        updateLabels()
        updateCardViewData()

        guard let data = data else { return }

        if data.monthlyGoalStats.goal > 0,
           ((currentGoalView as? GoalAndStatsCardView) != nil),
           lastEntriesCollectionView != nil {
            updateGoalViewData()
            updateCollectionHeight()
        } else {
            updateGoalViewContainer()
            updateGoalViewData()
            updateLastEntriesContainer()
        }

    }
    
    // MARK: - Setup View components
    private func setupUI() {
        view.backgroundColor = .designBackground
        navigationController?.navigationBar.barTintColor = .designBackground
        // Сначала создаем и добавляем все view в иерархию
        setupScrollView()
        setupContentView()
        setupTopView()
        setupCardView()
        setupRecentActivityLabel()
        setupLastEntriesContainerView()
        
        // Теперь все view созданы и добавлены в иерархию
        // Можно безопасно создавать constraints
        setupConstraints()
    }
    
    private func setupTopView() {
        titleView.backgroundColor = .clear
        titleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleView) // ✅ Добавляем в contentView, не в scrollView
        
        greetingTitle.text = viewModel.lastTimeOfDay
        greetingTitle.font = .systemFont(ofSize: 15, weight: .regular)
        greetingTitle.textColor = .designBlack
        greetingTitle.backgroundColor = .clear
        
        
        let avatarImage = {
            let avatar = UIImageView(image: UIImage(named: "avatar"))
            avatar.contentMode = .scaleAspectFill
            avatar.layer.cornerRadius = 22.5
            avatar.clipsToBounds = true
            avatar.backgroundColor = .systemGray5 // Fallback цвет
            return avatar
        }()
        
        let nameTitle = {
            let title = UILabel()
            // FIXME: Привязать к имени юзера
            title.text = "Anna Smith"
            title.font = .systemFont(ofSize: 27, weight: .bold)
            title.textColor = .designBlack
            title.backgroundColor = .clear
            return title
        }()
        //FIXME: - Сделать изменения иконки в зависимости наличия непрочитанных уведомлений
        let notificationButton = {
            let button = UIButton(type: .system)
            let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
            
            let normalImage = UIImage(systemName: "bell.badge", withConfiguration: config)?
                .withTintColor(.designBlack, renderingMode: .alwaysOriginal)
            let highlightedImage = UIImage(systemName: "bell.badge.fill", withConfiguration: config)?
                .withTintColor(.designPrimary, renderingMode: .alwaysOriginal)
            
            button.setImage(normalImage, for: .normal)
            button.setImage(highlightedImage, for: .highlighted)
            button.backgroundColor = .clear
            button.addTarget(self, action: #selector(openNotifications), for: .touchUpInside)
            button.projectAnimationForButtons()
            return button
        }()
        
        
        let elements = [avatarImage, notificationButton, greetingTitle, nameTitle]
        elements.forEach { 
            $0.translatesAutoresizingMaskIntoConstraints = false
            titleView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // Avatar constraints
            avatarImage.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            avatarImage.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            avatarImage.widthAnchor.constraint(equalToConstant: 45),
            avatarImage.heightAnchor.constraint(equalToConstant: 45),
            
            // Greeting title constraints
            greetingTitle.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 12),
            greetingTitle.topAnchor.constraint(equalTo: titleView.topAnchor),
            
            // Name title constraints
            nameTitle.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 12),
            nameTitle.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            
            // Notification button constraints
            notificationButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            notificationButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            notificationButton.widthAnchor.constraint(equalToConstant: 36),
            notificationButton.heightAnchor.constraint(equalToConstant: 36)

        ])
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
        contentView.backgroundColor = .designBackground
        scrollView.addSubview(contentView)
    }
    
    private func setGoalView(_ newView: UIView) {
        // ШАГ 1: Сначала деактивируем constraint, связывающий recentActivityStackView с текущим goalView
        // Это критически важно сделать ДО удаления старого view
        if let constraint = recentActivityTopConstraint {
            constraint.isActive = false
            recentActivityTopConstraint = nil
        }
        
        // ШАГ 2: Деактивируем constraints старого goalView
        NSLayoutConstraint.deactivate(goalViewConstraints)
        goalViewConstraints.removeAll()
        
        // ШАГ 3: Удаляем старое view из иерархии
        currentGoalView?.removeFromSuperview()
        
        // ШАГ 4: Устанавливаем новое view как текущее
        currentGoalView = newView
        
        // ШАГ 5: Настраиваем новое view и добавляем его в иерархию
        newView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(newView)
        
        // ШАГ 6: Создаем и активируем constraints для нового goalView
        goalViewConstraints = [
            newView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20),
            newView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            newView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            newView.heightAnchor.constraint(equalToConstant: 200)
        ]
        NSLayoutConstraint.activate(goalViewConstraints)
        
        // ШАГ 7: Используем асинхронный вызов для создания constraint
        // Это гарантирует что все view полностью встроены в иерархию перед созданием constraint
        // Асинхронность дает системе время завершить layout цикл
        DispatchQueue.main.async { [weak self] in
            self?.updateRecentActivityConstraint()
        }
        
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            titleView.heightAnchor.constraint(equalToConstant: 48),
            
            cardView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            cardView.heightAnchor.constraint(equalToConstant: 200),
            
            // ВАЖНО: НЕ создаем здесь constraint для recentActivityStackView.topAnchor
            // Он будет создан динамически в updateRecentActivityConstraint()
            recentActivityStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 27),
            recentActivityStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            lastEntriesContainerView.topAnchor.constraint(equalTo: recentActivityStackView.bottomAnchor, constant: 20),
            lastEntriesContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            lastEntriesContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            lastEntriesContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)

        ])
        
    }
    
    private func setupCardView(){
        cardView.backgroundColor = .designBackground
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.4
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
        cardView.layer.shadowRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
    }
    
    private func setupEmptyGoalView() {
        let emptyGoalView = EmptyGoalView()
        emptyGoalView.backgroundColor = .chartsBackground
        emptyGoalView.layer.cornerRadius = 20
        emptyGoalView.layer.shadowColor = UIColor.black.cgColor
        emptyGoalView.layer.shadowOpacity = 0.4
        emptyGoalView.layer.shadowOffset = CGSize(width: 0, height: 10)
        emptyGoalView.layer.shadowRadius = 12
        emptyGoalView.translatesAutoresizingMaskIntoConstraints = false
        setGoalView(emptyGoalView)
    }
    
    private func setupGoalAndStatsCardView() {
        let goalAndStatsCard = GoalAndStatsCardView()
        goalAndStatsCard.backgroundColor = .chartsBackground
        goalAndStatsCard.layer.cornerRadius = 20
        goalAndStatsCard.layer.shadowColor = UIColor.black.cgColor
        goalAndStatsCard.layer.shadowOpacity = 0.4
        goalAndStatsCard.layer.shadowOffset = CGSize(width: 0, height: 10)
        goalAndStatsCard.layer.shadowRadius = 12
        goalAndStatsCard.translatesAutoresizingMaskIntoConstraints = false
        goalAndStatsCard.actionForViewBtnStats = { [weak self] in
            self?.tabBarController?.selectedIndex = 1
        }
        
        setGoalView(goalAndStatsCard)
    }
    
    private func setupRecentActivityLabel(){
        let recentLabel = UILabel()
        let seeAllButton = UIButton()
        recentLabel.text = "Recent Activity"
        recentLabel.textColor = .designBlack
        recentLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        
        var config = UIButton.Configuration.plain()
        config.title = "See All"
        
        seeAllButton.configuration = config
        seeAllButton.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration
            switch button.state {
            case .normal:
                    updatedConfig?.baseForegroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            case .highlighted:
                updatedConfig?.baseForegroundColor = #colorLiteral(red: 0.05708128214, green: 0.507697165, blue: 0.2824192047, alpha: 1)
            default:
                updatedConfig?.baseForegroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            }
            button.configuration = updatedConfig
        }
        seeAllButton.addTarget(self, action: #selector(actionSeeAll), for: .touchUpInside)
        
        recentActivityStackView.addArrangedSubview(recentLabel)
        recentActivityStackView.addArrangedSubview(seeAllButton)
        recentActivityStackView.axis = .horizontal
        recentActivityStackView.alignment = .fill
        recentActivityStackView.distribution = .equalSpacing
        recentActivityStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(recentActivityStackView)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout )
        collectionView.register(IncomeCollectionViewCell.self,
                                         forCellWithReuseIdentifier: IncomeCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        lastEntriesContainerView.addSubview(collectionView)
        NSLayoutConstraint.activate([
               collectionView.topAnchor.constraint(equalTo: lastEntriesContainerView.topAnchor),
               collectionView.leadingAnchor.constraint(equalTo: lastEntriesContainerView.leadingAnchor),
               collectionView.trailingAnchor.constraint(equalTo: lastEntriesContainerView.trailingAnchor),
               collectionView.bottomAnchor.constraint(equalTo: lastEntriesContainerView.bottomAnchor)
           ])
        lastEntriesCollectionView = collectionView
        updateCollectionHeight()
    }
    
    private func setupEmptyDataView(){
        let emptyView = EmptyDataView(title: "No Income Resourced Added Yet", 
                                      description: "Click “Add New Income” Button To Start Tracking")
        emptyView.backgroundColor = .clear
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        lastEntriesContainerView.addSubview(emptyView)
        NSLayoutConstraint.activate([
                emptyView.topAnchor.constraint(equalTo: lastEntriesContainerView.topAnchor),
                emptyView.leadingAnchor.constraint(equalTo: lastEntriesContainerView.leadingAnchor),
                emptyView.trailingAnchor.constraint(equalTo: lastEntriesContainerView.trailingAnchor),
                emptyView.bottomAnchor.constraint(equalTo: lastEntriesContainerView.bottomAnchor),
                emptyView.heightAnchor.constraint(equalToConstant: 300) // или нужная высота
            ])
        emptyDataView = emptyView
    }
    
    private func setupLastEntriesContainerView(){
        lastEntriesContainerView.backgroundColor = .clear
        lastEntriesContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lastEntriesContainerView)
    }
    
    //MARK: - Updates
    private func updateCardViewData(){
        guard let data = data else { return }
        cardView.updateData(
            total: data.cardData.totalVolume,
            paid: data.cardData.paidVolume,
            pending: data.cardData.unpaidVolume
        )
    }
    
    private func updateLastEntriesContainer(){
        lastEntriesContainerView.subviews.forEach { $0.removeFromSuperview() }
        lastEntriesCollectionView = nil
        emptyDataView = nil
        guard let data = data else { return }
        if data.lastEntries.isEmpty {
            setupEmptyDataView()
        } else {
            setupCollectionView()
        }
    }
    
    private func updateLabels(){
        greetingTitle.text = viewModel.lastTimeOfDay
    }
    
    private func updateRecentActivityConstraint() {
        // КРИТИЧЕСКИ ВАЖНО: сначала деактивируем и удаляем старый constraint
        print("updateRecentActivityConstraint")
        if let oldConstraint = recentActivityTopConstraint {
            oldConstraint.isActive = false
            recentActivityTopConstraint = nil
        }
        
        // Создаем новый constraint только после того, как убедимся что goalView существует и добавлен в иерархию
        guard let goalView = currentGoalView,
              goalView.superview != nil else {
            print("⚠️ Warning: Cannot create constraint - goalView is not in view hierarchy")
            return
        }
        
        // Создаем и сразу активируем новый constraint
        let newConstraint = recentActivityStackView.topAnchor.constraint(
            equalTo: goalView.bottomAnchor, 
            constant: 20
        )
        newConstraint.isActive = true
        
        // Сохраняем ссылку на новый constraint
        recentActivityTopConstraint = newConstraint
        
        // Форсируем обновление layout
        contentView.setNeedsLayout()
    }
    
    private func updateGoalViewData(){
        print("updateGoalViewData")
        // Обновляем только если view точно является GoalAndStatsCardView
        if let goalView = currentGoalView as? GoalAndStatsCardView {
            goalView.setGoalValues(
                current: data?.monthlyGoalStats.total ?? 0,
                goal: data?.monthlyGoalStats.goal ?? 0
            )
            goalView.setStatsValues(newvalues: data?.lastMonthStats ?? [])
            goalView.actionForViewBtnStats = { [weak self] in
                self?.tabBarController?.selectedIndex = 1
            }
        }
    }

    private func updateGoalViewContainer() {
        print("updateGoalViewContainer")
        guard let data = data else { return }
        let goalExists = data.monthlyGoalStats.goal > 0.0
        if goalExists {
            // Создаем GoalAndStatsCardView только если его еще нет или если текущее view - EmptyGoalView
            if !(currentGoalView is GoalAndStatsCardView) {
                setupGoalAndStatsCardView()
            }
        } else {
            // Создаем EmptyGoalView только если его еще нет или если текущее view - GoalAndStatsCardView
            if !(currentGoalView is EmptyGoalView) {
                setupEmptyGoalView()
            }
        }
    }

    private func updateCollectionHeight() {
        print("updateCollectionHeight")
        lastEntriesCollectionView?.reloadData()
        lastEntriesCollectionView?.layoutIfNeeded()

        let newHeight = lastEntriesCollectionView?.contentSize.height ?? 0

        if let oldConstraint = lastEntriesCollectionView?.constraints.first(where: { $0.firstAttribute == .height }) {
            lastEntriesCollectionView?.removeConstraint(oldConstraint)
        }
        lastEntriesCollectionView?.heightAnchor.constraint(equalToConstant: newHeight + 10).isActive = true

        UIView.animate(withDuration: 0.3) {
            self.lastEntriesContainerView.layoutIfNeeded()
        }
    }

    private func showAlert(title: String, message: String) {
        let customAlert = CustomAlert(title: title,
                                      message: message)
        let okAction = AlertAction(title: "OK", style: .baseDefault) { [weak self] in
            print("showAlert <OK> button action")
        }
        customAlert.addAction(okAction)
        customAlert.showAlert(from: self)
    }

    //MARK: Actions
    @objc
    private func openNotifications() {
        print("Написать тело функции просмотра уведомлений")
    }

    @objc
    private func actionSeeAll(){
        tabBarController?.selectedIndex = 3
    }

    //MARK: - View Life cycles
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Обновляем размер градиента под размер view
        if let gradientLayer = cardView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = cardView.bounds
     
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        updateLabels()
    }
    
}

// MARK: - UICollectionView DataSource & Delegate
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = data else { return 0 }
        let collectionViewEntries = data.lastEntries
        return collectionViewEntries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = lastEntriesCollectionView?.dequeueReusableCell(
            withReuseIdentifier: IncomeCollectionViewCell.reuseIdentifier, for: indexPath
        ) as! IncomeCollectionViewCell
        guard let data = data else { return cell}
        let collectionViewEntries = data.lastEntries
        // Безопасный доступ к данным
        if indexPath.item < collectionViewEntries.count {
            let item = collectionViewEntries[indexPath.item]
            cell.configure(with: item)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        if cell.layer.animation(forKey: "wobbleAnimation") != nil {
            cell.layer.removeAnimation(forKey: "wobbleAnimation")
        } else {
            let animation = drainAnimate()
            cell.layer.add(animation, forKey: "wobbleAnimation")
        }
    }

    private func drainAnimate() -> CAAnimation {
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.values = [0, 10, -10, 0]
        shake.duration = 0.1
        shake.repeatCount = 2
        return shake
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width // отступы по 8 с каждой стороны
        let height: CGFloat = 100 // высота как у TableView ячейки, можете настроить
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if let incomeCell = cell as? IncomeCollectionViewCell {
            incomeCell.animateAppearance(delayMultiplier: indexPath.row)
            
        }
    }
    
}


extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }
        let currentOffset = scrollView.contentOffset.y
        let difference = currentOffset - lastContentOffset
        let threshold: CGFloat = 50 // Минимальное расстояние для срабатывания
        
        if abs(difference) > 5 { // Избегаем мелких движений
            if difference > 0 && currentOffset > threshold {
                // Прокрутка вниз - скрываем
                animateTabBar(hide: true)
            } else if difference < 0 {
                // Прокрутка вверх - показываем
                animateTabBar(hide: false)
            }
        }
        
        lastContentOffset = currentOffset
    }
    
    private func animateTabBar(hide: Bool) {
        guard let tabBarController = tabBarController else { return }
        
        let tabBar = tabBarController.tabBar
//        let safeAreaBottom = view.safeAreaInsets.bottom
        
        let hiddenY = view.frame.height + 30
        let visibleY = view.frame.height - tabBar.frame.height/* - safeAreaBottom*/
        
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
