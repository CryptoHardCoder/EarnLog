//
//  FlippableProgressChart.swift
//  EarnLog
//
//  Created by M3 pro on 07/09/2025.
//
import UIKit

final class GoalAndStatsCardView: FlippableView {
    
    let goalChartView = SemicircleProgressChart()
//    let goalChartViewContainer = UIView()
    let back = UIView()
//    override var frontView: UIView { goalChartViewContainer }
//    override var backView: UIView { back }
    
    init() {
        super.init(frontView: goalChartView, backView: back)
        goalChartView.frame = bounds
        back.frame = bounds
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
        setupGoalView()
        back.backgroundColor = .red
//        back.translatesAutoresizingMaskIntoConstraints = false
//        goalChartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(back)
        addSubview(goalChartView)
//        NSLayoutConstraint.activate([
//            goalChartView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            goalChartView.centerYAnchor.constraint(equalTo: centerYAnchor),
//            goalChartView.widthAnchor.constraint(equalToConstant: 360),
//            goalChartView.heightAnchor.constraint(equalToConstant: 200)
//            
//        ])
    }
    
    private func setupGoalView() {
        goalChartView.setValues(current: 4000, total: 10000)
//        goalChartView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(goalChartViewContainer)
//        
//        // Добавляем chart внутрь контейнера
//        goalChartView.translatesAutoresizingMaskIntoConstraints = false
//        goalChartViewContainer.addSubview(goalChartView)
//        
//        NSLayoutConstraint.activate([
//            goalChartView.topAnchor.constraint(equalTo: goalChartViewContainer.topAnchor),
//            goalChartView.leadingAnchor.constraint(equalTo: goalChartViewContainer.leadingAnchor),
//            goalChartView.trailingAnchor.constraint(equalTo: goalChartViewContainer.trailingAnchor),
//            goalChartView.bottomAnchor.constraint(equalTo: goalChartViewContainer.bottomAnchor)
//        ])
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        back.frame = bounds
        goalChartView.frame = bounds
    }
    
  
}

