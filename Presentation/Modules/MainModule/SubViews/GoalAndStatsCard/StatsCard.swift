//
//  StatsCard.swift
//  EarnLog
//
//  Created by M3 pro on 07/09/2025.

import SwiftUI
import Charts


// MARK: - UIKit StatsCard
class StatsCard: UIView {
    
    private var statsData = [(String, Double)]()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let viewButton = UIButton()
    private let titleStack = UIStackView()
    private let dataStackView = UIStackView()
    
    private var hostingController: UIHostingController<PieChartSwiftUI>?
    
    var onViewButtonTap: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView(){
        backgroundColor = .clear
        layer.cornerRadius = 20
        setupTitle()
        setupChart()
        setupDataLabel()
        setupConstraints()
    }
    
    private func setupTitle(){
        titleLabel.text = "income_breakdown".localized
        titleLabel.textColor = DSColors.appTextPrimary
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .left
        
        
        let dateComponents = Calendar.current.dateComponents([.month, .year], from: .now)
        let monthInt = dateComponents.month
        let year = dateComponents.year

        let dateFormatter = DateFormatter()
        let arrayMonthNames = dateFormatter.shortMonthSymbols
        
        guard let monthInt = monthInt, 
            let year = year,
            let monthNames = arrayMonthNames else { return }
        
        let monthString = monthNames[monthInt-1].capitalized
        
        dateLabel.text = "\(monthString)\(year)"
        dateLabel.textColor = DSColors.appTextPrimary
        dateLabel.font = .systemFont(ofSize: 18, weight: .bold)
        dateLabel.textAlignment = .center
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        var config = UIButton.Configuration.plain()
        config.title = "view".localized
        config.baseForegroundColor = DSColors.StatsCardColors.viewButtonColor
        config.image = UIImage(systemName: "chevron.forward", withConfiguration: symbolConfig)
        config.titleAlignment = .automatic
        config.imagePlacement = .trailing
        config.imagePadding = 5
        viewButton.configuration = config
        viewButton.addTarget(self, action: #selector(handleViewButton), for: .touchUpInside)
        
        [titleLabel, dateLabel, viewButton].forEach {
            titleStack.addArrangedSubview($0)
        }
        titleStack.axis = .horizontal
        titleStack.alignment = .fill
        titleStack.distribution = .equalSpacing
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleStack)
    }

    private func setupChart(){
        // Встраиваем SwiftUI PieChart вместо UIImageView
        let chartData = statsData.map { PieChartData(name: $0.0, value: Double($0.1)) }
        let chart = PieChartSwiftUI(data: chartData)
        
        let hosting = UIHostingController(rootView: chart)
        hostingController = hosting
        
        guard let hostingView = hosting.view else { return }
        hostingView.backgroundColor = .clear
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: titleStack.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            hostingView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10),
            hostingView.widthAnchor.constraint(equalToConstant: 140),
            hostingView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    private func setupDataLabel(){
        let data = createStacksWithData(with: statsData)
        makeStacks(items: data)
        dataStackView.axis = .horizontal
        dataStackView.spacing = 30
        dataStackView.alignment = .center
        dataStackView.distribution = .fill
        dataStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dataStackView)
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            titleStack.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            titleStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
//            dataStackView.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 10),
            dataStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            dataStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 160),
            dataStackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10)
//            dataStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30)
        ])
    }
    
    private func makeKeyRow(text: String, color: UIColor) -> UIStackView {
        let circle = UIView()
        circle.backgroundColor = color
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = 6
        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: 12),
            circle.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = .systemFont(ofSize: 16, weight: .medium)
        
        let row = UIStackView(arrangedSubviews: [circle, label])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }
    
    private func makeStacks(items: [UIStackView]) {
        dataStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in items {
            dataStackView.addArrangedSubview(item)
        }
    }
    
    private func createStacksWithData(with items: [(String, Double)]) -> [UIStackView] {
        let namesStack = UIStackView()
        namesStack.axis = .vertical
        namesStack.spacing = 10
        namesStack.alignment = .leading
        
        let valuesStack = UIStackView()
        valuesStack.axis = .vertical
        valuesStack.spacing = 10
        valuesStack.alignment = .trailing
        
        for (index, (key, value)) in items.enumerated() {
            let colors: [UIColor] = [
                DSColors.StatsCardColors.mainJobStatsColor,
                DSColors.StatsCardColors.secondarySideJobColor,
                DSColors.StatsCardColors.tertiarySideJobColor,
                DSColors.StatsCardColors.smallestSideJobColor ]

            let color = colors[index % colors.count]
            
            let keyRow = makeKeyRow(text: key, color: color)
            namesStack.addArrangedSubview(keyRow)
            
            let valueLabel = UILabel()
            valueLabel.text = "\(value.formattedWithSpaces)$"
            valueLabel.textColor = color
            valueLabel.numberOfLines = 0
            valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
            valueLabel.textAlignment = .right
            valuesStack.addArrangedSubview(valueLabel)
        }
        
        return [namesStack, valuesStack]
    }
    
    @objc
    private func handleViewButton(){
        onViewButtonTap?()
    }
    
    //MARK: - Public Methods
    func setNewStatsData(newStats: [(String, Double)]) {
        self.statsData = newStats.sorted(by: { $0.1 > $1.1 })

        // обновляем легенду справа
        let newStacksData = createStacksWithData(with: statsData)
        makeStacks(items: newStacksData)
        
        // обновляем чарт
        let chartData = statsData.map { PieChartData(name: $0.0, value: Double($0.1)) }
        hostingController?.rootView = PieChartSwiftUI(data: chartData)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}

@available(iOS 17.0, *)
#Preview {
    StatsCard()
}
