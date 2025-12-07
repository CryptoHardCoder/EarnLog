//
//  SemicircleProgressChart.swift
//  EarnLog
//
//  Created by M3 pro on 03/09/2025.
//

import UIKit

// MARK: - Configuration
struct ProgressChartConfiguration {
    var lineWidth: CGFloat = 30
    var baseColor: UIColor = DSColors.gray.withAlphaComponent(0.6)
    var backgroundColor: UIColor = DSColors.gray.withAlphaComponent(0.4)
    var animationDuration: TimeInterval = 2.0
    var labelAnimationDuration: TimeInterval = 2.0
    var currencySymbol: String = "$"
}

final class SemicircleProgressChart: UIView {
    
    // MARK: - Public Properties
    var configuration = ProgressChartConfiguration() {
        didSet { applyConfiguration() }
    }
    
    // MARK: - Private UI Elements
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    private let valueLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let motivationLabel = UILabel()
    private let monthlyGoalTitle = UILabel()
    private let goalLevelView = UIView()
    private let levelText = UILabel()
    
    // MARK: - Private Properties
    private var isAnimating = false
    private var animationCompletion: (() -> Void)?

    private var progress: CGFloat = 0.0
    
    private var currentValue: Double = 0.0 {
        didSet {
            updateProgressFromValues()
        }
    }
    private var userGoalValue: Double = 0.0
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        setupLayers()
        setupLabels()
        applyConfiguration()
    }
    
    private func setupLayers() {
        backgroundLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(backgroundLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = DSColors.black.cgColor
        progressLayer.strokeEnd = 0.0
        
        gradientLayer.type = .axial
        gradientLayer.mask = progressLayer
        layer.addSublayer(gradientLayer)
        updateGradientColors()
    }
    
    private func setupLabels() {
        monthlyGoalTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        monthlyGoalTitle.text = "Monthly Goal"
        monthlyGoalTitle.textColor = DSColors.appTextPrimary
        monthlyGoalTitle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(monthlyGoalTitle)
        
        levelText.font = .systemFont(ofSize: 15, weight: .semibold)
        levelText.textColor = DSColors.MonthlyGoalCardColors.levelTitleColor
        levelText.textAlignment = .center
        levelText.translatesAutoresizingMaskIntoConstraints = false
        goalLevelView.addSubview(levelText)
        
        goalLevelView.translatesAutoresizingMaskIntoConstraints = false
        goalLevelView.backgroundColor = DSColors.MonthlyGoalCardColors.levelBackgroundColor
        goalLevelView.layer.cornerRadius = 5
        addSubview(goalLevelView)
        
        valueLabel.font = UIFont.boldSystemFont(ofSize: 28)
        valueLabel.textColor = DSColors.appTextPrimary
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        descriptionLabel.textColor = DSColors.appTextPrimary
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            monthlyGoalTitle.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            monthlyGoalTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            
            goalLevelView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            goalLevelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            goalLevelView.widthAnchor.constraint(equalToConstant: 70),
            goalLevelView.heightAnchor.constraint(equalToConstant: 25),
            
            levelText.centerXAnchor.constraint(equalTo: goalLevelView.centerXAnchor),
            levelText.centerYAnchor.constraint(equalTo: goalLevelView.centerYAnchor),
            
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 35),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
        ])
    }
    
    private func applyConfiguration() {
        backgroundLayer.lineWidth = configuration.lineWidth
        progressLayer.lineWidth = configuration.lineWidth
        backgroundLayer.strokeColor = configuration.backgroundColor.cgColor
        
        updateGradientColors()
        setNeedsLayout()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        backgroundLayer.frame = bounds
        gradientLayer.frame = bounds
        progressLayer.frame = bounds
        gradientLayer.mask = progressLayer
        if bounds.width > 0 && bounds.height > 0 {
            updateGradientColors()
        }
        updatePath()
        
        CATransaction.commit()
    }
    
    // MARK: - Updates
    private func updateProgress() {
        progressLayer.strokeEnd = progress
    }
    
    private func updatePath() {
        let center = CGPoint(x: bounds.midX, y: bounds.maxY - configuration.lineWidth / 2)
        let radius = max(bounds.width, bounds.height) / 2 - configuration.lineWidth * 2
        let startAngle = CGFloat.pi
        let endAngle: CGFloat = 0
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        backgroundLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }
    
    private func updateProgressFromValues() {
        guard userGoalValue > 0 else { return }
        let newProgress = CGFloat(currentValue) / CGFloat(userGoalValue)
        progress = min(max(newProgress, 0.0), 1.0)
    }
    
    private func updateGradientColors() {
        guard bounds != .zero else { return }
//        let gradient = GreenGradients.greenForChart.layer(frame: bounds, view: self)
        let gradient = GradientFactory.makeLayer(colors: DSColors.MonthlyGoalCardColors.semiChartLineGradientColors,
                                                 start: DSColors.MonthlyGoalCardColors.gradientPoints.start,
                                                 end: DSColors.MonthlyGoalCardColors.gradientPoints.end,
                                                 frame: bounds)
        gradientLayer.colors = gradient.colors
        gradientLayer.startPoint = gradient.startPoint
        gradientLayer.endPoint = gradient.endPoint
        gradientLayer.locations = gradient.locations
        gradientLayer.frame = bounds
    }
    
    private func updateLabels() {
        // Обновляем статичные лейблы

        let userGoalValueString = userGoalValue.formattedWithSpaces
        descriptionLabel.text = "OUT OF \(configuration.currencySymbol)\(userGoalValueString)"

        levelText.text = {
            if progress < 0.4 || progress == 0.0 {
                return GoalLevels.low.rawValue.uppercased()
            } else if progress > 0.4 && progress < 0.7 {
                return GoalLevels.medium.rawValue.uppercased()
            } else {
                return GoalLevels.strong.rawValue.uppercased()
            }
        }()

        // Выводим прогресс только при изменении
//        print("progress: \(progress)")
    }
    
    // MARK: - Public Method
    func setValues(current: Double, goalValue: Double, completion: (() -> Void)? = nil) {
        guard current != currentValue || goalValue != userGoalValue else { return }
        
        let oldValue = currentValue
        
        // Обновляем значения
        userGoalValue = goalValue
        currentValue = current
        
        // Рассчитываем новый прогресс
        let newProgress = CGFloat(current) / CGFloat(goalValue)
        let clampedProgress = min(max(newProgress, 0.0), 1.0)
        
        // Обновляем статичные лейблы сразу
//        updateLabels()
        
        // Запускаем анимации синхронно через 1 секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Запускаем обе анимации одновременно
            self.animateValueLabel(
                from: oldValue,
                to: current,
                duration: self.configuration.labelAnimationDuration
            )
            
            self.animateProgress(
                to: clampedProgress,
                completion: completion
            )
            
//            updateLabels()
        }
    }
    
    
    // MARK: - Private Animation Methods
    private func animateProgress(to newProgress: CGFloat, duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        let animationDuration = duration ?? configuration.animationDuration
        
        progressLayer.removeAnimation(forKey: "strokeEnd")
        isAnimating = true
        
        let fromValue = (progressLayer.presentation()?.value(forKeyPath: "strokeEnd") as? CGFloat) ?? progressLayer.strokeEnd
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.toValue = newProgress
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.progressLayer.strokeEnd = newProgress
            self?.progress = newProgress
            self?.isAnimating = false
            self?.updateLabels()
            // НЕ вызываем updateLabels здесь, чтобы избежать дублирования
            completion?()
        }
        
        progressLayer.add(animation, forKey: "strokeEnd")
        CATransaction.commit()
    }
    
    private func stopAnimation() {
        progressLayer.removeAnimation(forKey: "strokeEnd")
        isAnimating = false
        animationCompletion = nil
    }
    
    private func animateValueLabel(from startValue: Double, to endValue: Double, duration: TimeInterval) {
        let startTime = CACurrentMediaTime()
        let diff = endValue - startValue
        
        let displayLink = CADisplayLink(withTarget: BlockTarget { [weak self] in
            let elapsed = CACurrentMediaTime() - startTime
            let progress = min(elapsed / duration, 1.0)
            let eased = 1 - pow(1 - progress, 3)
            let value = startValue + diff * eased
            let valueString = value.formattedWithSpaces
            
            self?.valueLabel.text = "\(self?.configuration.currencySymbol ?? "$")\(valueString)"
            
            if progress >= 1.0 {
                $0.invalidate()
                let endValueString = endValue.formattedWithSpaces
                self?.valueLabel.text = "\(self?.configuration.currencySymbol ?? "$")\(endValueString)"
            }
        })
        
        displayLink.add(to: .main, forMode: .default)
        
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        
//        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//            updateGradientColors()
//        }
//    }
    
}

// Simple helper to use CADisplayLink with closure
private class BlockTarget {
    private let block: (CADisplayLink) -> Void
    init(_ block: @escaping (CADisplayLink) -> Void) { self.block = block }
    @objc func tick(_ link: CADisplayLink) { block(link) }
}

private extension CADisplayLink {
    convenience init(withTarget blockTarget: BlockTarget) {
        self.init(target: blockTarget, selector: #selector(BlockTarget.tick(_:)))
    }
}
