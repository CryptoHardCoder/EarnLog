////
////  CardView.swift
////  EarnLog
////
////  Created by M3 pro on 06/09/2025.
////
//
import UIKit

// MARK: - CardView
class CardView: FlippableView {
    
    private var totalValue: Double?
    private var paidValue: Double?
    private var pendingValue: Double?
    private let front = UIView()
    private let back = UIView()
    
    private let totalIncomeValueLabel = UILabel()
    private let paidValueLabel = UILabel()
    private let pendingValueLabel = UILabel()
    
    init() {
        super.init(frontView: front, backView: back)
        setupFrontView()
        setupBackView()
        updateUI()
    }
    
//    init(totalValue: Double, paidValue: Double, pendingValue: Double) {
//        self.totalValue = totalValue
//        self.paidValue = paidValue
//        self.pendingValue = pendingValue
//        super.init(frontView: front, backView: back)
//        setupFrontView()
//        setupBackView()
//        updateUI()
//    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - FRONT
    private func setupFrontView() {
        front.layer.cornerRadius = 18
        setupGradientLayer(in: front)
        setupTopComponents(in: front)
        setupBottomComponents(in: front)
    }
    
    // MARK: - BACK
    private func setupBackView() {
        back.layer.cornerRadius = 18
        
        let label = UILabel()
        label.text = "Back side"
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        back.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: back.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: back.centerYAnchor)
        ])
    }
    
    // MARK: - GRADIENT
    private func setupGradientLayer(in view: UIView) {
        gradient = AppGradients.greenForCard.layer(frame: bounds, view: view)
        gradient?.cornerRadius = 18
        if let gradientLayer = gradient {
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    // MARK: - TOP COMPONENTS
    private func setupTopComponents(in view: UIView) {
        let totalIncomeText = UILabel()
        totalIncomeText.text = "Total Income"
        totalIncomeText.font = .systemFont(ofSize: 18, weight: .semibold)
        totalIncomeText.textColor = .white
        totalIncomeText.translatesAutoresizingMaskIntoConstraints = false
        
        totalIncomeValueLabel.text = String(format: "$ %.2f", totalValue ?? 0.0 )
        totalIncomeValueLabel.font = .systemFont(ofSize: 27, weight: .bold)
        totalIncomeValueLabel.textColor = .white
        totalIncomeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [totalIncomeText, totalIncomeValueLabel])
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
        ])
    }
    
    // MARK: - BOTTOM COMPONENTS
    private func setupBottomComponents(in view: UIView) {
        let paidComponent = createComponents(iconName: "chekmarkVector", text: "Paid", valueLabel: paidValueLabel)
        let pendingComponent = createComponents(iconName: "pending-actions_icon_3x", text: "Pending", valueLabel: pendingValueLabel, right: true)
        
        let stackView = UIStackView(arrangedSubviews: [paidComponent, pendingComponent])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
    }
    
    private func createComponents(iconName: String, text: String, valueLabel: UILabel, right: Bool = false) -> UIView {
        let icon = UIImageView(image: UIImage(named: iconName))
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .white
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

//        valueLabel.text = String(format: "$ %.2f", value)
        valueLabel.font = .systemFont(ofSize: 23, weight: .medium)
        valueLabel.textColor = .white
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.addSubview(icon)
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let rightConstraints = [
            icon.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -5),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ]
        
        let leftConstraints = [
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 5),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor)
        ]
        
        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 15),
            icon.heightAnchor.constraint(equalToConstant: 15),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        if right {
            NSLayoutConstraint.activate(rightConstraints)
        } else {
            NSLayoutConstraint.activate(leftConstraints)
        }
        
        return container
    }
    
    // MARK: - ОБНОВЛЕНИЕ ДАННЫХ
   func updateData(total: Double, paid: Double, pending: Double){
       totalValue = total
       paidValue = paid
       pendingValue = pending
       updateUI()
   }
   
   private func updateUI() {
       totalIncomeValueLabel.text = String(format: "$ %.2f", totalValue ?? 0.0)
       paidValueLabel.text = String(format: "$ %.2f", paidValue ?? 0.0)
       pendingValueLabel.text = String(format: "$ %.2f", pendingValue ?? 0.0)
   }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            gradient?.colors = AppGradients.greenForCard.layer(frame: bounds).colors
        }
    }
}
