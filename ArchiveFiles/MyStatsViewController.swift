//
//import UIKit
//import SwiftUI
//import Charts
//
//class StatsViewController: UIViewController {
//    
//    private let titleLabel = UILabel()
//    
//    private var groupedItems = [DailyTotal]()
//    
//    private var filteredItems: [CarEntry] = []
//    
//    private let segmentController = UISegmentedControl(items: TimeFilter.allCases.map{$0.localizedTitle})
//    
//    private var currentFilterInterval: TimeFilter = .day
//    
//    private var chartView: BarChart = BarChart(groupedItems: [DailyTotal]())
//    
//    private var hostingController: UIHostingController<BarChart>!
//    
//    private var targetValue: Double {
//        return UserDefaults.standard.double(forKey: "targetValue")
//    }
//    
//    private let summaryLabel: UILabel = {
//        
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.textColor = .systemBlue
//        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 15 // 👉 между строками
//        paragraphStyle.alignment = .center
//
//        let attributes: [NSAttributedString.Key: Any] = [
//            .paragraphStyle: paragraphStyle,
//            .font: label.font as Any
//        ]
//        label.attributedText = NSAttributedString(string: "...", attributes: attributes)
//        return label
//    }()
//    
//    private let totalText: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let paidLabel = UILabel()
//    private let unPaidLabel = UILabel()
//    
//    private let dailyAverageLAbel = UILabel()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupUI()
//        // Подписываемся на обновления данных
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(dataDidUpdate),
//            name: .dataDidUpdate,
//            object: nil
//        )
//        
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    @objc private func dataDidUpdate() {
//        refreshData()
//    }
//    
//    private func refreshData(){
//        filteredItems = AppFileManager.shared.getFilteredItems(for: currentFilterInterval)
//        groupedItems = AppFileManager.shared.getDailyTotal(items: filteredItems)
//        updateLabels(items: filteredItems)
//          // заново создаём график с новой линией
//        hostingController.rootView = BarChart(groupedItems: groupedItems, targetValue: targetValue)
//    }
//    private func setupUI(){
//        view.backgroundColor = .systemBackground
//        
//        titleLabel.text = "stats".localized
//        titleLabel.font = .systemFont(ofSize: 25, weight: .semibold)
//        navigationItem.titleView = titleLabel
//        
//        segmentController.layer.cornerRadius = 14
//        segmentController.backgroundColor = .systemBackground
//        segmentController.selectedSegmentIndex = 0
//        segmentController.setTitleTextAttributes( [.font: UIFont.systemFont(ofSize: 18)], for: .normal)
//        segmentController.addTarget(self, action: #selector(segmentControllerValueChanged), for: .valueChanged)
//        segmentController.translatesAutoresizingMaskIntoConstraints = false
//        
//        chartView = BarChart(groupedItems: groupedItems, targetValue: targetValue)
//
//        hostingController = UIHostingController(rootView: chartView)
//        addChild(hostingController)
//        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(hostingController.view)
//        hostingController.didMove(toParent: self)
//        
//        paidLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        paidLabel.textColor = .systemGreen
//        paidLabel.textAlignment = .center
//        
//        unPaidLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        unPaidLabel.textColor = .systemOrange
//        unPaidLabel.textAlignment = .center
//        
//        dailyAverageLAbel.font = .systemFont(ofSize: 18, weight: .medium)
//        dailyAverageLAbel.textAlignment = .center
//        
//        let statsStackView = UIStackView(arrangedSubviews: [summaryLabel, paidLabel, unPaidLabel, dailyAverageLAbel])
//        statsStackView.axis = .vertical
//        statsStackView.distribution = .fillEqually
//        statsStackView.spacing = 8
//        statsStackView.alignment = .center
//        statsStackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(segmentController)
////        view.addSubview(summaryLabel)
//        view.addSubview(statsStackView)
//
//        NSLayoutConstraint.activate([
//            segmentController.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            segmentController.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            segmentController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            segmentController.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            hostingController.view.topAnchor.constraint(equalTo: segmentController.bottomAnchor, constant: 20),
//            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
////            summaryLabel.topAnchor.constraint(equalTo: hostingController.view.bottomAnchor, constant: 20),
////            summaryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            
//            statsStackView.topAnchor.constraint(equalTo: hostingController.view.bottomAnchor, constant: 20),
//            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
//            
//        ])
//        
//    }
//    
//    // MARK: - Обновление статистики
//    private func updateLabels(items: [CarEntry]) {
//        let stats = AppFileManager.shared.getStatics(for: items)
//        let totalString = String(format: "%.0f zł", stats.total)
//        let intervalName: String
//        switch currentFilterInterval{
//            case .week: intervalName = "неделю"
//            
//            default: intervalName = currentFilterInterval.localizedTitle.lowercased()
//        }
//        
//        let color: UIColor = {
//            if stats.dailyAverage < 500 {
//               return .systemRed
//            } else if stats.dailyAverage < 800 {
//                return .systemOrange
//            } else if stats.dailyAverage < 1200 {
//                return .systemBlue
//            } else {
//                return .systemGreen
//            }
//        }()
//
//        summaryLabel.text = "💰 \("total_for_the".localized) \(intervalName): \(totalString)"
//        summaryLabel.textColor = .systemBlue
//        
//        paidLabel.text = String(format: "✅ \("paid".localized): %.2f zł", stats.paid)
//        unPaidLabel.text = String(format: "❌ \("unPaid".localized): %.2f zł", stats.unPaid)
//        
//        dailyAverageLAbel.textColor = color
//        dailyAverageLAbel.text = String(format: "⚖ \("average_title".localized): %.2f zł", stats.dailyAverage)
//        
//    }
//    @objc private func segmentControllerValueChanged() {
//        currentFilterInterval = TimeFilter.allCases[segmentController.selectedSegmentIndex]
//        refreshData()
//    }
//}
