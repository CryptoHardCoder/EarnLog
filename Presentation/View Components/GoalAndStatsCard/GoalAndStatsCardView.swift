//
//  FlippableProgressChart.swift
//  EarnLog
//
//  Created by M3 pro on 07/09/2025.
//
import UIKit

final class GoalAndStatsCardView: FlippableView {
    
    private let goalChartView = SemicircleProgressChart()
    private let statsCardView = StatsCard()
    
    var actionForViewBtnStats: (()->Void)? {
        didSet {
            statsCardView.onViewButtonTap = actionForViewBtnStats
        }
    }
    
    init() {
        super.init(frontView: goalChartView, backView: statsCardView)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
//        setGoalValues()
    }
    
    func setGoalValues(current: Int = 0, goal: Int = 0) {
        goalChartView.setValues(current: current, goalValue: goal)
    }
    
    func setStatsValues(newvalues: [(String, Int)] ){
        statsCardView.setNewStatsData(newStats: newvalues)
    }

}
    


//// MARK: - CardView односторонний
//class ExcampleCardView: UIView {
//    
//    private let totalValue: Double
//    private let paidValue: Double
//    private let pendingValue: Double
//    private let front = UIView()
//    private var gradient = CAGradientLayer()
//
//    init(totalValue: Double, paidValue: Double, pendingValue: Double) {
//        
//        self.totalValue = totalValue
//        self.paidValue = paidValue
//        self.pendingValue = pendingValue
//        super.init(frame: .zero)
//        setupFrontView()
//    }
//    
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        gradient.frame = bounds
//    }
//    // MARK: - FRONT
//    private func setupFrontView() {
////        front.frame = bounds
//        front.layer.cornerRadius = 18
//        setupGradientLayer(in: front)
//        setupTopComponents(in: front)
//        setupBottomComponents(in: front)
//        front.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(front)
//        NSLayoutConstraint.activate([
//            front.leadingAnchor.constraint(equalTo: leadingAnchor),
//            front.trailingAnchor.constraint(equalTo: trailingAnchor),
//            front.topAnchor.constraint(equalTo: topAnchor),
//            front.bottomAnchor.constraint(equalTo: bottomAnchor),
//            
//        ])
//    }
//    
//    // MARK: - GRADIENT
//    private func setupGradientLayer(in view: UIView) {
//        gradient = AppGradients.greenForCard.layer(frame: bounds, view: view)
//        gradient.cornerRadius = 18
//        view.layer.insertSublayer(gradient, at: 0)
////        if let gradientLayer = gradient {
////            view.layer.insertSublayer(gradientLayer, at: 0)
////        }
//    }
//    
//    // MARK: - TOP COMPONENTS
//    private func setupTopComponents(in view: UIView) {
//        let totalIncomeText = UILabel()
//        totalIncomeText.text = "Total Income"
//        totalIncomeText.font = .systemFont(ofSize: 18, weight: .semibold)
//        totalIncomeText.textColor = .white
//        totalIncomeText.translatesAutoresizingMaskIntoConstraints = false
//        
//        let totalIncomeValue = UILabel()
//        totalIncomeValue.text = String(format: "$ %.2f", totalValue)
//        totalIncomeValue.font = .systemFont(ofSize: 27, weight: .bold)
//        totalIncomeValue.textColor = .white
//        totalIncomeValue.translatesAutoresizingMaskIntoConstraints = false
//        
//        let stack = UIStackView(arrangedSubviews: [totalIncomeText, totalIncomeValue])
//        stack.axis = .vertical
//        stack.spacing = 5
//        stack.alignment = .leading
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(stack)
//        NSLayoutConstraint.activate([
//            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
//            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
//        ])
//    }
//    
//    // MARK: - BOTTOM COMPONENTS
//    private func setupBottomComponents(in view: UIView) {
//        let paidComponent = createComponents(iconName: "chekmarkVector", text: "Paid", value: paidValue)
//        let pendingComponent = createComponents(iconName: "pending-actions_icon_3x", text: "Pending", value: pendingValue, right: true)
//        
//        let stackView = UIStackView(arrangedSubviews: [paidComponent, pendingComponent])
//        stackView.axis = .horizontal
//        stackView.alignment = .fill
//        stackView.distribution = .fillProportionally
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(stackView)
//        NSLayoutConstraint.activate([
//            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
//            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
//            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
//        ])
//    }
//    
//    private func createComponents(iconName: String, text: String, value: Double, right: Bool = false) -> UIView {
//        let icon = UIImageView(image: UIImage(named: iconName))
//        icon.contentMode = .scaleAspectFit
//        icon.tintColor = .white
//        icon.translatesAutoresizingMaskIntoConstraints = false
//        
//        let titleLabel = UILabel()
//        titleLabel.text = text
//        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
//        titleLabel.textColor = .white
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        let valueLabel = UILabel()
//        valueLabel.text = String(format: "$ %.2f", value)
//        valueLabel.font = .systemFont(ofSize: 23, weight: .medium)
//        valueLabel.textColor = .white
//        valueLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        let container = UIView()
//        container.addSubview(icon)
//        container.addSubview(titleLabel)
//        container.addSubview(valueLabel)
//        container.translatesAutoresizingMaskIntoConstraints = false
//        
//        let rightConstraints = [
//            icon.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -5),
//            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
//            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
//        ]
//        
//        let leftConstraints = [
//            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 5),
//            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor)
//        ]
//        
//        NSLayoutConstraint.activate([
//            icon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
//            icon.widthAnchor.constraint(equalToConstant: 15),
//            icon.heightAnchor.constraint(equalToConstant: 15),
//            
//            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
//            
//            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
//            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
//        ])
//        
//        if right {
//            NSLayoutConstraint.activate(rightConstraints)
//        } else {
//            NSLayoutConstraint.activate(leftConstraints)
//        }
//        
//        return container
//    }
//    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//            gradient.colors = AppGradients.greenForCard.layer(frame: bounds).colors
//        }
//    }
//}
