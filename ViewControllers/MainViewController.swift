//
//  MainViewController.swift
//  EarnLog
//
//  Created by M3 pro on 30/07/2025.
//


//
//  MainViewController.swift (VIEW в MVVM)
//  JobData
//
//  Created by M3 pro on 13/07/2025.
//
import Foundation
import UIKit

// MARK: - вариант для установки переворачивающиеся второй карточки -> goalAndStatsCard = GoalAndStatsCardView()
final class MainViewController: UIViewController, MemoryTrackable {
    
    private var lastContentOffset: CGFloat = 0
    
    // MARK: - ViewModel
    private let viewModel = MainViewModel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView() // ✅ Добавляем контейнер для контента
    private let goalAndStatsCard = GoalAndStatsCardView()
    private let titleView = UIView()
    private let cardView = CardView()
    private var greetingTitle = UILabel()

//    private let cardView = CardView(totalValue: 2540.00, 
//                                    paidValue: 1850.00,
//                                    pendingValue: 1950.45)
    private let layout = UICollectionViewFlowLayout()
    private let recentActivityStackView = UIStackView()
    private lazy var lastEntriesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout )
    
    init() {
        super.init(nibName: nil, bundle: nil)
        trackCreation()
//        reloadData()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .designBackground
        navigationController?.navigationBar.barTintColor = .designBackground
        setupView()
        reloadData()
        bindViewModel()
    }
    
    private func bindViewModel() {
        // 📢 Слушаем изменения данных
        viewModel.onDataChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.reloadData()
            }
        }
    }
    
    private func reloadData(){
        lastEntriesCollectionView.reloadData()
        updateCardData()
        updateLabels()
//        updateGoalData()
        updateStatsCard()
        
    }
    
    private func setupView(){
        setupScrollView()
        setupContentView()
        setupTopView()
        setupCardView()
        setupGoalView()
        setupRecentLabel()
        setupCollectionView()
        setupConstraints()
        
        updateGoalData()
    }
    
    // MARK: - ScrollView Setup
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
//        scrollView.showsHorizontalScrollIndicator = false
        
        view.addSubview(scrollView)
    }
    
    // MARK: - Content View Setup
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .designBackground
        scrollView.addSubview(contentView)
    }
    
    // MARK: - TitleView Full setup
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
    
    //MARK: - Card View Setup
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
    
    private func setupGoalView() {
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
        contentView.addSubview(goalAndStatsCard)
    }
    
    private func setupRecentLabel(){
        let recentLabel = UILabel()
        let seeAllButton = UIButton()
        recentLabel.text = "Recent Activity"
        recentLabel.textColor = .designBlack
        recentLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        
        var config = UIButton.Configuration.plain()
        config.title = "See All"
//        config.baseForegroundColor = .black300
        
        
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
    
    // MARK: - UICollectionView Setup
    private func setupCollectionView() {
        // Создаем layout для CollectionView
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
//        layout.minimumInteritemSpacing = 8
//        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        // Инициализируем CollectionView с layout
        lastEntriesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        // Регистрируем ячейку
        lastEntriesCollectionView.register(IncomeCollectionViewCell.self,
                                         forCellWithReuseIdentifier: IncomeCollectionViewCell.reuseIdentifier)
        // Устанавливаем делегаты
        lastEntriesCollectionView.dataSource = self
        lastEntriesCollectionView.delegate = self
        
        // Настройки внешнего вида
//        lastEntriesCollectionView.backgroundColor = .red
        lastEntriesCollectionView.showsVerticalScrollIndicator = true
        lastEntriesCollectionView.showsHorizontalScrollIndicator = false
        
        // Настройки Auto Layout
        lastEntriesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lastEntriesCollectionView)
    }

    
    //FIXME: Написать метод обновления данных здесь
    private func updateGoalData(){
        let data = viewModel.getMonthlyGoalStats()
        goalAndStatsCard.setGoalValues(current: data.total, goal: data.goal)
    }
    
    private func updateLabels(){
        greetingTitle.text = viewModel.lastTimeOfDay
    }
    
    private func updateCardData(){
        let data = viewModel.getIncomeDataForCard()
        print("data:\(data)")
        cardView.updateData(total: data.totalVolume, paid: data.paidVolume, pending: data.unpaidVolume)
    }
    
    private func updateStatsCard(){
        let newData = viewModel.getLastMonthStats()
        print("updateStatsCard:\(newData)")
        goalAndStatsCard.setStatsValues(newvalues: newData)
    }
    
    
    // MARK: - Constraints Setup
    private func setupConstraints() {
        
        let entriesCount = viewModel.lastEntries.count
        let validHeight = entriesCount <= 5 ? entriesCount : 5
        
        NSLayoutConstraint.activate([
            // ✅ ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ✅ ContentView constraints (важно для скролла!)
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor), // ✅ Ключевое ограничение!
            
            // ✅ TitleView constraints
            titleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            titleView.heightAnchor.constraint(equalToConstant: 48),
            
            cardView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            cardView.heightAnchor.constraint(equalToConstant: 200),
            
            goalAndStatsCard.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20),
            goalAndStatsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            goalAndStatsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            goalAndStatsCard.heightAnchor.constraint(equalToConstant: 200),
            
            recentActivityStackView.topAnchor.constraint(equalTo: goalAndStatsCard.bottomAnchor, constant: 20),
            recentActivityStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 27),
            recentActivityStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            lastEntriesCollectionView.topAnchor.constraint(equalTo: recentActivityStackView.bottomAnchor, constant: 20),
            lastEntriesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            lastEntriesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            //FIXME: Как сделать так чтобы высота сама определялась в зависимости от количества ячеек

            lastEntriesCollectionView.heightAnchor.constraint(equalToConstant: CGFloat(validHeight * 110) ), // ✅ Добавьте фиксированную высоту
            
            // ✅ Добавляем нижний constraint для contentView, чтобы скролл работал
            lastEntriesCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor/*, constant: -20*/)
 
        ])
        
    }
    
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
        updateGoalData()
    }
    
}

// MARK: - UICollectionView DataSource & Delegate
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("collectionView: \(viewModel.lastEntries)")
        if viewModel.lastEntries.count > 5 {
            return 5
        }
        return viewModel.lastEntries.count // ✅ Безопасный доступ
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = lastEntriesCollectionView.dequeueReusableCell(withReuseIdentifier: IncomeCollectionViewCell.reuseIdentifier,
                                                               for: indexPath) as! IncomeCollectionViewCell
                
        // Безопасный доступ к данным
        if indexPath.item < viewModel.lastEntries.count {
            let item = viewModel.lastEntries[indexPath.item]
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

@available(iOS 17.0, *)
#Preview {
    MainViewController()
    
}

// MARK: первый рабочий вариант 
//final class MainViewController: UIViewController, MemoryTrackable {
//    // MARK: - ViewModel 🏃‍♂️ (наш официант)
//    private let viewModel = MainViewModel()
//    
//    private let scrollView = UIScrollView()
//    private let contentView = UIView() // ✅ Добавляем контейнер для контента
//    private let goalChartView = SemicircleProgressChart()
//    private let titleView = UIView()
//    private let cardView = CardView(totalValue: 2540.00, paidValue: 1850.00, pendingValue: 1950.45)
//    private let goalView = UIView()
//    private let chartView = UIView()
//    private let recentActivityStackView = UIStackView()
//    private let lastEntriesView = UITableView()
//    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//        trackCreation()
//    }
//        
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        navigationController?.navigationBar.barTintColor = .designBackground
//        
//        setupView()
//    }
//    
//    private func setupView(){
//        setupScrollView()
//        setupContentView()
//        setupTopView()
//        setupCardView()
//        setupGoalView()
//        setupConstraints()
//        
//        updateGoalData()
//    }
//    
//    // MARK: - ScrollView Setup
//    private func setupScrollView() {
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.alwaysBounceVertical = true
//        scrollView.backgroundColor = .clear
//        scrollView.showsVerticalScrollIndicator = false
////        scrollView.showsHorizontalScrollIndicator = false
//        
//        view.addSubview(scrollView)
//    }
//    
//    // MARK: - Content View Setup
//    private func setupContentView() {
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.backgroundColor = .clear
//        scrollView.addSubview(contentView)
//    }
//    
//    // MARK: - TitleView Full setup
//    private func setupTopView() {
//        titleView.backgroundColor = .clear
//        titleView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(titleView) // ✅ Добавляем в contentView, не в scrollView
//        
//        let avatarImage = {
//            let avatar = UIImageView(image: UIImage(named: "avatar"))
//            avatar.contentMode = .scaleAspectFill
//            avatar.layer.cornerRadius = 22.5
//            avatar.clipsToBounds = true
//            avatar.backgroundColor = .systemGray5 // Fallback цвет
//            return avatar
//        }()
//        
//        let greetingTitle = {
//            let title = UILabel()
//            // FIXME: Сделать универсальные варианты: вечер, утро, ночь, день 
//            title.text = "Good afternoon ☀️,"
//            title.font = .systemFont(ofSize: 15, weight: .regular)
//            title.textColor = .designBlack
//            title.backgroundColor = .clear
//            return title
//        }()
//        
//        let nameTitle = {
//            let title = UILabel()
//            // FIXME: Привязать к имени юзера
//            title.text = "Anna Smith"
//            title.font = .systemFont(ofSize: 27, weight: .bold)
//            title.textColor = .designBlack
//            title.backgroundColor = .clear
//            return title
//        }()
//        //FIXME: - Сделать изменения иконки в зависимости наличия непрочитанных уведомлений
//        let notificationButton = {
//            let button = UIButton(type: .system)
//               let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
//               
//               let normalImage = UIImage(systemName: "bell.badge", withConfiguration: config)?
//                   .withTintColor(.designBlack, renderingMode: .alwaysOriginal)
//               let highlightedImage = UIImage(systemName: "bell.badge.fill", withConfiguration: config)?
//                   .withTintColor(.designPrimary, renderingMode: .alwaysOriginal)
//               
//               button.setImage(normalImage, for: .normal)
//               button.setImage(highlightedImage, for: .highlighted)
//               button.backgroundColor = .clear
//               button.addTarget(self, action: #selector(openNotifications), for: .touchUpInside)
//               return button
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
//    //MARK: - Card View Setup
//    private func setupCardView(){
//        cardView.backgroundColor = .designBackground
//        cardView.layer.cornerRadius = 20
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.4
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
//        cardView.layer.shadowRadius = 12
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(cardView)
//    }
//    
//    private func setupGoalView() {
//        goalView.backgroundColor = .chartsBackground
//        goalView.layer.cornerRadius = 20
//        goalView.layer.shadowColor = UIColor.black.cgColor
//        goalView.layer.shadowOpacity = 0.4
//        goalView.layer.shadowOffset = CGSize(width: 0, height: 10)
//        goalView.layer.shadowRadius = 12
//        goalView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(goalView)
//
//        // Добавляем chart внутрь контейнера
//        goalChartView.translatesAutoresizingMaskIntoConstraints = false
//        goalView.addSubview(goalChartView)
//
//        NSLayoutConstraint.activate([
//            goalChartView.topAnchor.constraint(equalTo: goalView.topAnchor),
//            goalChartView.leadingAnchor.constraint(equalTo: goalView.leadingAnchor),
//            goalChartView.trailingAnchor.constraint(equalTo: goalView.trailingAnchor),
//            goalChartView.bottomAnchor.constraint(equalTo: goalView.bottomAnchor)
//        ])
//    }
//    //FIXME: Написать метод обновления данных здесь
//    private func updateGoalData(){
//        goalChartView.setValues(current: 7000, total: 10000)
//    }
//    
//    // MARK: - Constraints Setup
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // ✅ ScrollView constraints
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            // ✅ ContentView constraints (важно для скролла!)
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor), // ✅ Ключевое ограничение!
//            
//            // ✅ TitleView constraints
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
//            goalView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20),
//            goalView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
//            goalView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
//            goalView.heightAnchor.constraint(equalToConstant: 200),
//            
//            // ✅ Добавляем нижний constraint для contentView, чтобы скролл работал
//            goalView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
//        ])
//        
//    }
//    
//    @objc
//    private func openNotifications() {
//        print("Написать тело функции просмотра уведомлений")
//    }
//    //MARK: - View Life cycles
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        // Обновляем размер градиента под размер view
//        if let gradientLayer = cardView.layer.sublayers?.first as? CAGradientLayer {
//            gradientLayer.frame = cardView.bounds
//     
//        }
//    }
//    
//}

//MARK: первый рабочий вариант (сырой дизайн)
//final class MainViewController: UIViewController, MemoryTrackable {
//    
//    // MARK: - ViewModel 🏃‍♂️ (наш официант)
//    private let viewModel = MainViewModel()
//    
//    // MARK: - UI Components 🎨 (это и есть VIEW в MVVM!)
//    private let contentView = UIView()
//    private let scrollView = UIScrollView()
//    private let titleLabel = UILabel()
//    private var selectedSource: IncomeSource? = nil
//    private var menuButton = UIButton(type: .system)
//    
//    private var goalLeftLabel: UILabel = {
//        let leftlabel = UILabel()
//        leftlabel.text = "goal_for_the_day".localized
//        leftlabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        leftlabel.textColor = .systemBlue
//        return leftlabel
//    }()
//    
//    private var goalTextField = UITextField()
//    private var goalTextFieldContainer = UIView()
//    private let dateLabel = UILabel()
//    private let automobileTextField = UITextField()
//    private let priceTextField = UITextField()
//    private let saveButton = UIButton()
//    private let tableView = UITableView()
//    private let segmentController = UISegmentedControl(items: TimeFilter.allCases.map{$0.localizedTitle})
//    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//        trackCreation()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Lifecycle 🔄
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = .systemBackground
//        setupUI()
//        bindViewModel() // 🔗 Связываем с ViewModel
//        setupNotifications()
//        hideKeyboard()
//        
////        print(AppFileManager.shared.allItems)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//       super.viewWillAppear(animated)
//       // Обновляем данные каждый раз когда экран появляется
//       // Это покроет случаи возврата из других экранов
//        viewModel.updateCurrentDate()
//       }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//        trackDeallocation()
//    }
//    
//    // MARK: - Notifications 📢
//    private func setupNotifications(){
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(dataDidUpdate),
//            name: .dataDidUpdate,
//            object: nil
//        )
//        // Добавляем новые для даты
//      NotificationCenter.default.addObserver(
//          self,
//          selector: #selector(appDidBecomeActive),
//          name: UIApplication.didBecomeActiveNotification,
//          object: nil
//      )
//    }
//    
//    @objc private func dataDidUpdate() {
//        viewModel.refreshData() // 🏃‍♂️ ViewModel обновляет данные
//    }
//    
//    @objc private func appDidBecomeActive() {
//           viewModel.updateCurrentDate()
//       }
//    
//    // MARK: - ViewModel Binding 🔗 (НАТИВНО, без библиотек!)
//    private func bindViewModel() {
//        // 📢 Слушаем изменения данных
//        viewModel.onDataChanged = { [weak self] in
//            DispatchQueue.main.async {
//                self?.updateMenu()
//                self?.tableView.reloadData()
//            }
//        }
//        
//        // 📢 Слушаем изменения цели
//        viewModel.onGoalChanged = { [weak self] in
//            DispatchQueue.main.async {
//                self?.updateGoalUI()
//            }
//        }
//        
//        // Добавляем binding для даты
//       viewModel.onDateChanged = { [weak self] in
//           DispatchQueue.main.async {
//               self?.updateDateUI()
//           }
//       }
//        
//////         📢 Слушаем изменения фильтра
////        viewModel.onFilterChanged = { [weak self] in
////            DispatchQueue.main.async {
////                // Можно добавить анимацию смены фильтра
////            }
////        }
//        
//        // Устанавливаем начальные значения
//        updateGoalUI()
//        updateDateUI()
//        
//    }
//    
//    private func setupMenuButton(){
//        menuButton.setTitle("select_source".localized, for: .normal)
//        menuButton.setTitleColor(.systemBlue, for: .normal)
//        menuButton.setTitleColor(.systemBlue, for: .highlighted)
//        menuButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
//        menuButton.layer.borderWidth = 1
//        menuButton.layer.borderColor = UIColor.systemGray.cgColor
//        menuButton.layer.cornerRadius = 14
//        menuButton.showsMenuAsPrimaryAction = true
////        menuButton.translatesAutoresizingMaskIntoConstraints = false
//        updateMenu()
//    }
//    
//    private func updateMenu() {
//        showMainMenu()
//    }
//
//    private func showMainMenu() {
//        
//        var mainMenuItems: [UIMenuElement] = []
//        
//        // Ищем основную работу и сразу создаем action если есть
//        if let mainJobSource = viewModel.sources.first(where: { source in
//            if case .mainJob = source { return true }
//            return false
//        }) {
//            let mainJobAction = UIAction(title: "primary".localized) { _ in
//                self.selectedSource = mainJobSource
//                self.menuButton.setTitle(mainJobSource.displayName, for: .normal)
////                print("Выбран источник: \(mainJobSource.displayName)")
//            }
//            mainMenuItems.append(mainJobAction)
//        }
//        
//        // Создаём подменю для подработок если они есть
//        let sideJobSources = viewModel.sources.compactMap { source -> (String, IncomeSource)? in
//            if case .sideJob(let job) = source, job.isActive {
//                return (job.name, source)
//            }
//            return nil
//        }
//        
//        if !sideJobSources.isEmpty {
//            let sideJobActions = sideJobSources.map { (name, source) in
//                UIAction(title: name) { _ in
//                    self.selectedSource = source
//                    self.menuButton.setTitle(name, for: .normal)
////                    print("Выбрана подработка: \(name)")
//                }
//            }
//            
//            let sideJobMenu = UIMenu(title: "part_time".localized, children: sideJobActions)
//            mainMenuItems.append(sideJobMenu)
//        }
//        
//        // Назначаем меню кнопке
//        menuButton.menu = UIMenu(title: "", children: mainMenuItems)
//        menuButton.showsMenuAsPrimaryAction = true
//    }
//    // MARK: - UI Updates (View реагирует на изменения ViewModel)
//    private func updateGoalUI() {
//        goalTextField.text = viewModel.dailyGoal
//        goalTextField.isEnabled = viewModel.isGoalEnabled
//        
//        if viewModel.isGoalEnabled {
//            goalTextField.becomeFirstResponder()
//        }
//    }
//    
//    private func updateDateUI() {
//        dateLabel.text = "🗓️ \(viewModel.todayDate)"
//    }
//    
//  
//        
//    // MARK: - UI Setup 🎨
//    private func setupUI() {
//        setupScrollView()
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        
//        titleLabel.text = "earn_log".localized
//        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
//        navigationItem.titleView = titleLabel
//        
//        goalTextFieldContainer = setupGoalTextFieldView()
////        goalTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
//        
//        dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
//        dateLabel.textAlignment = .center
//        dateLabel.textColor = .label
////        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        setupTextFields()
//        setupMenuButton()
//        setupSaveButton()
//        setupTableView()
//        setupSegmentController()
//        
//        // Добавляем вьюхи
//        [goalTextFieldContainer,
//         dateLabel,
//         automobileTextField,
//         priceTextField,
//         menuButton,
//         saveButton,
//         tableView,
//         segmentController].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
////            contentView.addSubview($0)
//            view.addSubview($0)
//        }
//        
//        setupConstraints()
//    }
//    
//    private func setupTextFields() {
//        // Автомобиль
//        automobileTextField.placeholder = "mark_or_model".localized
//        automobileTextField.layer.cornerRadius = 14
//        automobileTextField.layer.borderWidth = 1
//        automobileTextField.layer.borderColor = UIColor.systemGray.cgColor
//        automobileTextField.textAlignment = .center
//        automobileTextField.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        automobileTextField.tag = 1
////        automobileTextField.translatesAutoresizingMaskIntoConstraints = false
//        automobileTextField.addTarget(self, action: #selector(textFieldShouldReturn), for: .editingDidEndOnExit)
//        
//        // Цена
//        priceTextField.placeholder = "price".localized
//        priceTextField.layer.cornerRadius = 14
//        priceTextField.layer.borderWidth = 1
//        priceTextField.layer.borderColor = UIColor.systemGray.cgColor
//        priceTextField.textAlignment = .center
//        priceTextField.keyboardType = .decimalPad
//        priceTextField.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        priceTextField.tag = 2
////        priceTextField.translatesAutoresizingMaskIntoConstraints = false
//        priceTextField.addTarget(self, action: #selector(textFieldShouldReturn), for: .touchUpInside)
//    }
//    
//    private func setupSaveButton() {
//        saveButton.setTitle("save".localized, for: .normal)
//        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
//        saveButton.setTitleColor(.white, for: .normal)
//        saveButton.backgroundColor = .systemBlue
//        saveButton.layer.cornerRadius = 14
//        saveButton.projectAnimationForButtons()
//        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
////        saveButton.translatesAutoresizingMaskIntoConstraints = false
//    }
//    
//    private func setupTableView() {
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.register(IncomeTableViewCell.self,
//                           forCellReuseIdentifier: IncomeTableViewCell.reuseIdentifier)
////        tableView.translatesAutoresizingMaskIntoConstraints = false
////        tableView.layer.borderColor = UIColor.systemGray.cgColor
//    }
//    
//    private func setupSegmentController() {
//        segmentController.layer.cornerRadius = 14
//        segmentController.backgroundColor = .systemBackground
//        segmentController.selectedSegmentIndex = 0
//        segmentController.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 18)], for: .normal)
//        segmentController.addTarget(self, action: #selector(segmentControllerValueChanged), for: .valueChanged)
////        segmentController.translatesAutoresizingMaskIntoConstraints = false
//    }
//    
//    private func setupScrollView(){
////        view.addSubview(scrollView)
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.isUserInteractionEnabled = true
//        scrollView.isScrollEnabled = true
//        scrollView.showsVerticalScrollIndicator = true
//        scrollView.delaysContentTouches = false
//        scrollView.canCancelContentTouches = true
//        scrollView.alwaysBounceVertical = true
//        scrollView.addSubview(contentView)
//    }
//    
//    // MARK: - Goal TextField Setup
//    func setupGoalTextFieldView() -> UIView {
//        let containerView = UIView()
//        goalTextField = setupGoalTextField()
//        goalTextField.translatesAutoresizingMaskIntoConstraints = false
//        goalLeftLabel.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(goalLeftLabel)
//        containerView.addSubview(goalTextField)
//        
//        NSLayoutConstraint.activate([
//            goalLeftLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
//            goalLeftLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
//            goalLeftLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
//            
//            goalTextField.topAnchor.constraint(equalTo: containerView.topAnchor),
//            goalTextField.leadingAnchor.constraint(equalTo: goalLeftLabel.trailingAnchor, constant: 0),
//            goalTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
//        ])
//        
//        // Добавляем gesture recognizer на контейнер
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(enableEditingGoal))
//        doubleTap.numberOfTapsRequired = 2
//        containerView.addGestureRecognizer(doubleTap)
//        
//        goalTextField.addTarget(self, action: #selector(saveGoal), for: .editingDidEnd)
//        goalTextField.addTarget(self, action: #selector(saveGoal), for: .editingDidEndOnExit)
//        
//        return containerView
//    }
// 
//    func setupGoalTextField() -> UITextField {
//        let textField = UITextField()
//        textField.placeholder = "0"
//        textField.textColor = .systemBlue
//        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        textField.textAlignment = .center
//        textField.keyboardType = .numberPad
//        
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let flexSpace2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let doneButton = UIBarButtonItem(title: "Done",
//                                         style: .done,
//                                         target: self,
//                                         action: #selector(dismissKeyboard))
//
//        toolbar.setItems([flexSpace, doneButton, flexSpace2], animated: false)
//        textField.inputAccessoryView = toolbar
//
//        return textField
//    }
//    
//    // MARK: - Actions ⚡ (VIEW просто передает команды ViewModel!)
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//
//    @objc func enableEditingGoal() {
//        viewModel.enableGoalEditing() // 🏃‍♂️ ViewModel делает работу
//    }
//
//    @objc func saveGoal() {
//        guard let text = goalTextField.text else { return }
//        viewModel.saveGoal(text) // 🏃‍♂️ ViewModel сохраняет
//        goalTextField.resignFirstResponder()
//    }
//
//    @objc private func segmentControllerValueChanged() {
//        viewModel.changeFilterByIndex(segmentController.selectedSegmentIndex) // 🏃‍♂️ ViewModel меняет фильтр
//    }
//    
//    private func showAlert(message: String){
//        let alert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//
//    
//    @objc func saveButtonTapped() {
//        // Сразу проверяем что source не nil
//        guard let source = selectedSource else {
//            showAlert(message: "error_source".localized)
//            return
//        }
//        
//        // 🏃‍♂️ ViewModel проверяет данные
//        let (result, message) = viewModel.validateCarEntryInput(
//            car: automobileTextField.text,
//            price: priceTextField.text,
//            source: source  // Передаем уже развернутый source
//        )
//        guard result else {
//            showAlert(message: message)
//            return
//        }
//        
//        let car = automobileTextField.text!
//        let price = Double(priceTextField.text!)!
//        
//        // 🏃‍♂️ ViewModel сохраняет данные
//        if viewModel.saveNewEntry(car: car, price: price, source: source) {
//            // 🧹 VIEW очищает поля только если успешно сохранили
//            automobileTextField.text = ""
//            priceTextField.text = ""
//            selectedSource = nil  // Сбрасываем в nil
//            menuButton.setTitle("select_source".localized, for: .normal)
//            view.endEditing(true)
//        }
//    }
//    
//    // MARK: - Constraints
//    private func setupConstraints(){
//        NSLayoutConstraint.activate([
//            // MARK: вариант с scrollView
////            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
////            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
////            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
////            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
////            
////            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
////            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
////            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
////            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
////            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
////            contentView.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor),
//            
////            goalTextFieldContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
////            goalTextFieldContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
////            goalTextFieldContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70),
////            goalTextFieldContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 70),
////            
////            dateLabel.topAnchor.constraint(equalTo: goalTextFieldContainer.bottomAnchor, constant: 20),
////            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
////            
////            automobileTextField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
////            automobileTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
////            automobileTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
////            automobileTextField.heightAnchor.constraint(equalToConstant: 50),
////            
////            priceTextField.topAnchor.constraint(equalTo: automobileTextField.bottomAnchor, constant: 20),
////            priceTextField.centerXAnchor.constraint(equalTo: automobileTextField.centerXAnchor),
////            priceTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
////            priceTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
////            priceTextField.heightAnchor.constraint(equalToConstant: 50),
////            
////            menuButton.topAnchor.constraint(equalTo: priceTextField.bottomAnchor, constant: 20),
////            menuButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
////            menuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
////            menuButton.heightAnchor.constraint(equalToConstant: 50),
////            
////            saveButton.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: 20),
////            saveButton.centerXAnchor.constraint(equalTo: menuButton.centerXAnchor),
////            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
////            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
////            saveButton.heightAnchor.constraint(equalToConstant: 50),
////            
////            segmentController.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
////            segmentController.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
////            segmentController.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
////            
////            tableView.topAnchor.constraint(equalTo: segmentController.bottomAnchor, constant: 20),
////            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
////            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
////            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
////            tableView.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//            // MARK: вариант без scrollView
//                
//                goalTextFieldContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//                goalTextFieldContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                goalTextFieldContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -70),
//                goalTextFieldContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70),
//                
//                dateLabel.topAnchor.constraint(equalTo: goalTextFieldContainer.bottomAnchor, constant: 20),
//                dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                
//                automobileTextField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
//                automobileTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
//                automobileTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
//                automobileTextField.heightAnchor.constraint(equalToConstant: 50),
//                
//                priceTextField.topAnchor.constraint(equalTo: automobileTextField.bottomAnchor, constant: 20),
//                priceTextField.centerXAnchor.constraint(equalTo: automobileTextField.centerXAnchor),
//                priceTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
//                priceTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
//                priceTextField.heightAnchor.constraint(equalToConstant: 50),
//                
//                menuButton.topAnchor.constraint(equalTo: priceTextField.bottomAnchor, constant: 20),
//                menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
//                menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
//                menuButton.heightAnchor.constraint(equalToConstant: 50),
//                
//                saveButton.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: 20),
//                saveButton.centerXAnchor.constraint(equalTo: menuButton.centerXAnchor),
//                saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
//                saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
//                saveButton.heightAnchor.constraint(equalToConstant: 50),
//                
//                segmentController.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
//                segmentController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
//                segmentController.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
//                
//                tableView.topAnchor.constraint(equalTo: segmentController.bottomAnchor, constant: 20),
//                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//        ])
//    }
//}
//
//// MARK: - Table View & Text Field Delegates
//extension MainViewController: UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if let nextField = view.viewWithTag(textField.tag + 1) as? UITextField {
//            nextField.becomeFirstResponder()
//        } else {
//            textField.resignFirstResponder()
//        }
//        return true
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.filteredEntries.count // 🏃‍♂️ Данные из ViewModel
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: IncomeTableViewCell.reuseIdentifier,
//                                                 for: indexPath) as! IncomeTableViewCell
//        
//        let entry = viewModel.filteredEntries[indexPath.row] // 🏃‍♂️ Данные из ViewModel
//        cell.configure(with: entry)
//        
////        // Настройка callback для чекмарка
////        cell.onCheckmarkTapped = { [weak self] in
////            self?.viewModel.togglePaymentStatus(for: entry.id) // 🏃‍♂️ ViewModel меняет статус
////        }
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
////        print("didSelectRowAt")
//    }
//    
//    
//}
