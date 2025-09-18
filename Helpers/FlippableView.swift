////
////  FlippableView.swift
////  EarnLog
////
////  Created by M3 pro on 07/09/2025.
////
//
//
//MARK: - 
import UIKit

class FlippableView: UIView {
    
    private(set) var isFlipped: Bool = false
    private var isSetupCompleted = false
    var gradient: CAGradientLayer?

    // Вью для фронта и бэка можно переопределять в наследниках
    var frontView: UIView 
    var backView: UIView 
    
    // MARK: - Инициализация
    
    init(frontView: UIView, backView: UIView) {
        self.frontView = frontView
        self.backView = backView
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient?.frame = bounds
    }
    
    // MARK: - Настройка
    
    private func setup() {
        guard !isSetupCompleted else { return }
//        addSubview(frontView)
//        addSubview(backView)
        frontView.translatesAutoresizingMaskIntoConstraints = false
        backView.translatesAutoresizingMaskIntoConstraints = false
        // Добавляем frontView только если его ещё нет
        if frontView.superview == nil {
           addSubview(frontView)
        }
        if backView.superview == nil {
           addSubview(backView)
        }
        // Constraints устанавливаем только если views были добавлены
        NSLayoutConstraint.activate([
            frontView.topAnchor.constraint(equalTo: topAnchor),
            frontView.leadingAnchor.constraint(equalTo: leadingAnchor),
            frontView.trailingAnchor.constraint(equalTo: trailingAnchor),
            frontView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            backView.topAnchor.constraint(equalTo: topAnchor),
            backView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        isSetupCompleted.toggle()
        backView.isHidden = !isFlipped
        addTap()
    }
    
    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(flip))
        addGestureRecognizer(tap)
    }
    
    @objc func flip() {
        let fromView = isFlipped ? backView : frontView
        let toView   = isFlipped ? frontView : backView
        isFlipped.toggle()
        
        if let gradient = gradient {
            gradient.removeFromSuperlayer()
            toView.layer.insertSublayer(gradient, at: 0)
            gradient.frame = bounds
        }
        
        UIView.transition(from: fromView,
                          to: toView,
                          duration: 0.5,
                          options: [.transitionFlipFromLeft, .showHideTransitionViews, .curveEaseInOut])
    }
}

