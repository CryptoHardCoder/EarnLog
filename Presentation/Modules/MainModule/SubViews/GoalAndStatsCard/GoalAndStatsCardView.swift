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
//        print("GoalAndStatsCardView inited")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
//        setGoalValues()
    }
    
    func setGoalValues(current: Double = 0, goal: Double = 0) {
        goalChartView.setValues(current: current, goalValue: goal)
    }
    
    func setStatsValues(newValues: [(String, Double)] ){
        statsCardView.setNewStatsData(newStats: newValues)
    }
    
    deinit {
        print("GoalAndStatsCardView deinited")
    }
}
