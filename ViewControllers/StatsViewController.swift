//
//  StatsViewController.swift
//  EarnLog
//
//  Created by M3 pro on 31/07/2025.
//

import UIKit
import SwiftUI
import Charts

final class StatsViewController: UIViewController, MemoryTrackable {
//    private let chartAndCardViewFlippable = GoalAndStatsCardView()
//    init(){
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
//        chartAndCardViewFlippable.backgroundColor = .chartsBackground
//        chartAndCardViewFlippable.layer.cornerRadius = 20
//        chartAndCardViewFlippable.layer.shadowColor = UIColor.black.cgColor
//        chartAndCardViewFlippable.layer.shadowOpacity = 0.4
//        chartAndCardViewFlippable.layer.shadowOffset = CGSize(width: 0, height: 10)
//        chartAndCardViewFlippable.layer.shadowRadius = 12
//        chartAndCardViewFlippable.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(chartAndCardViewFlippable)
//        
//        NSLayoutConstraint.activate([
//            chartAndCardViewFlippable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            chartAndCardViewFlippable.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            chartAndCardViewFlippable.widthAnchor.constraint(equalToConstant: 360),
//            chartAndCardViewFlippable.heightAnchor.constraint(equalToConstant: 200)
//        ])
//        
//    }
//}


    private let viewModel = StatsViewModel()
    
    private var menuButton = UIButton(type: .system)
    
    private var selectedSource: IncomeSource? = nil
    
    private let titleLabel = UILabel()
    
    private let segmentController = UISegmentedControl(items: TimeFilter.allCases.map{$0.localizedTitle})
    
    private var chartView: BarChart = BarChart(groupedItems: [DailyTotal]())
    
    private var hostingController: UIHostingController<BarChart>!
    
    private let summaryLabel: UILabel = {
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 15 // 👉 между строками
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: label.font as Any
        ]
        label.attributedText = NSAttributedString(string: "...", attributes: attributes)
        return label
    }()
    
    private let totalText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let paidLabel = UILabel()
    private let unPaidLabel = UILabel()
    
    private let dailyAverageLAbel = UILabel()
    
    init(){
        super.init(nibName: nil, bundle: nil)
        trackCreation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        viewModel.refreshData() // 👈 И эту для первоначальной загрузки данных
        // Подписываемся на обновления данных
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dataDidUpdate),
            name: .dataDidUpdate,
            object: nil
        )
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        trackDeallocation()
    }
    
    @objc private func dataDidUpdate() {
        viewModel.refreshData()
    }
    
    private func bindViewModel() {
        // 📢 Слушаем изменения данных
        viewModel.onDataChanged = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                    let groupedItems = self.viewModel.groupedItems
                    let targetValue = self.viewModel.targetValue // 👈 Исправлено
                    self.updateLabels()
                    self.updateMenu()
                    self.hostingController.rootView = BarChart(groupedItems: groupedItems,
                                                                      targetValue: targetValue)
            }
        }
    }
    
    private func setupMenuButton(){
        menuButton.setTitle("total".localized, for: .normal)
        menuButton.setTitleColor(.systemBlue, for: .normal)
        menuButton.setTitleColor(.systemBlue, for: .highlighted)
        menuButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
//        menuButton.layer.borderWidth = 1
//        menuButton.layer.borderColor = UIColor.systemGray.cgColor
//        menuButton.layer.cornerRadius = 14
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        updateMenu()
    }
    
    private func updateMenu() {
        showMainMenu()
    }
    
    private func showMainMenu() {
        var mainMenuItems: [UIMenuElement] = []
        
        // Основная работа с проверкой выбранного состояния
        if let mainJobSource = viewModel.sources.first(where: { source in
            if case .mainJob = source { return true }
            return false
        }) {
//            let isSelected = selectedSource != nil && selectedSource! == mainJobSource
            let mainJobAction = UIAction(
                title: "primary".localized,
//                state: isSelected ? .on : .off
            ) { _ in
                self.selectedSource = mainJobSource
                self.menuButton.setTitle(mainJobSource.displayName, for: .normal)
                self.viewModel.source = self.selectedSource
                self.viewModel.refreshData()
//                print("Выбран источник: \(mainJobSource.displayName)")
            }
            mainMenuItems.append(mainJobAction)
        }
        
        // Подработки с проверкой выбранного состояния
        let sideJobSources = viewModel.sources.compactMap { source -> (String, IncomeSource)? in
            if case .sideJob(let job) = source, job.isActive {
                return (job.name, source)
            }
            return nil
        }
        
        if !sideJobSources.isEmpty {
            let sideJobActions = sideJobSources.map { (name, source) in
//                let isSelected = selectedSource != nil && selectedSource! == source
                return UIAction(
                    title: name,
//                    state: isSelected ? .on : .off
                ) { _ in
                    self.selectedSource = source
                    self.menuButton.setTitle(name, for: .normal)
                    self.viewModel.source = self.selectedSource
                    self.viewModel.refreshData()
//                    print("Выбрана подработка: \(name)")
                }
            }
            
            let sideJobMenu = UIMenu(title: "part_time".localized, children: sideJobActions)
            mainMenuItems.append(sideJobMenu)
        }
        
        // "Общее" с галочкой по умолчанию
        let totalAction = UIAction(
            title: "total".localized,
//            state: selectedSource == nil ? .on : .off
        ) { _ in
            self.selectedSource = nil
            self.menuButton.setTitle("total".localized, for: .normal)
            self.viewModel.source = nil
            self.viewModel.refreshData()
//            print("Выбрано: Общее (все источники)")
        }
        mainMenuItems.append(totalAction)
        
        menuButton.menu = UIMenu(title: "", children: mainMenuItems)
    }
    
    private func setupUI(){
        view.backgroundColor = .systemBackground
        
        titleLabel.text = "stats".localized
        titleLabel.font = .systemFont(ofSize: 25, weight: .semibold)
        navigationItem.titleView = titleLabel
        
        setupMenuButton()
        
        segmentController.layer.cornerRadius = 14
        segmentController.backgroundColor = .systemBackground
        segmentController.selectedSegmentIndex = 0
        segmentController.setTitleTextAttributes( [.font: UIFont.systemFont(ofSize: 18)], for: .normal)
        segmentController.addTarget(self, action: #selector(segmentControllerValueChanged), for: .valueChanged)
        segmentController.translatesAutoresizingMaskIntoConstraints = false
        
        chartView = BarChart(groupedItems: viewModel.groupedItems, targetValue: viewModel.targetValue)

        hostingController = UIHostingController(rootView: chartView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        paidLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        paidLabel.textColor = .systemGreen
        paidLabel.textAlignment = .center
        
        unPaidLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        unPaidLabel.textColor = .systemOrange
        unPaidLabel.textAlignment = .center
        
        dailyAverageLAbel.font = .systemFont(ofSize: 18, weight: .medium)
        dailyAverageLAbel.textAlignment = .center
        
        let statsStackView = UIStackView(arrangedSubviews: [summaryLabel, paidLabel, unPaidLabel, dailyAverageLAbel])
        statsStackView.axis = .vertical
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 8
        statsStackView.alignment = .center
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(segmentController)
        view.addSubview(menuButton)
        view.addSubview(statsStackView)

        NSLayoutConstraint.activate([
            
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            menuButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor/*, constant: 10*/),
//            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor/*, constant: -10*/),
            
            segmentController.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: 10),
            segmentController.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentController.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            hostingController.view.topAnchor.constraint(equalTo: segmentController.bottomAnchor, constant: 20),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
//            summaryLabel.topAnchor.constraint(equalTo: hostingController.view.bottomAnchor, constant: 20),
//            summaryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statsStackView.topAnchor.constraint(equalTo: hostingController.view.bottomAnchor, constant: 20),
            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
        ])
        
    }
    
    // MARK: - Обновление статистики
    private func updateLabels() {
        
        let stats = viewModel.getStats()
        let totalString = String(format: "%.0f zł", stats.total)
        let intervalName: String
        switch viewModel.currentFilterInterval{
            case .week: intervalName = "неделю"
            
            default: intervalName = viewModel.currentFilterInterval.localizedTitle.lowercased()
        }
        
        let color: UIColor = {
            if stats.dailyAverage < 500 {
               return .systemRed
            } else if stats.dailyAverage < 800 {
                return .systemOrange
            } else if stats.dailyAverage < 1200 {
                return .systemBlue
            } else {
                return .systemGreen
            }
        }()

        summaryLabel.text = "💰 \("total_for_the".localized) \(intervalName): \(totalString)"
        summaryLabel.textColor = .systemBlue
        
        paidLabel.text = String(format: "\("paid_for_alert".localized): %.2f zł", stats.paid)
        unPaidLabel.text = String(format: "\("unpaid_for_alert".localized): %.2f zł", stats.unPaid)
        
        // Показываем dailyAverage только для mainJob или "Общее" (nil)
        if selectedSource == .mainJob || selectedSource == nil {
            dailyAverageLAbel.textColor = color
            dailyAverageLAbel.text = String(format: "⚖ \("average_title".localized): %.2f zł", stats.dailyAverage)
        } else {
            // Для всех подработок скрываем лейбл
            dailyAverageLAbel.text = ""
        }
        
    }
    @objc private func segmentControllerValueChanged() {
        viewModel.changeSegmentFilter(index: segmentController.selectedSegmentIndex)
    }
}


