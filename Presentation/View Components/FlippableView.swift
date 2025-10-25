//
//  FlippableView.swift
//  EarnLog
//
//  Created by M3 pro on 07/09/2025.

import UIKit

class FlippableView: UIView {
    
    private(set) var isFlipped: Bool = false
    private var isSetupCompleted = false
    var gradient: CAGradientLayer?

    var frontView: UIView 
    var backView: UIView?
    
    // MARK: - Initialization
    init(frontView: UIView, backView: UIView?) {
        self.frontView = frontView
        self.backView = backView
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View life cycles
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient?.frame = bounds
    }

    //MARK: - Setups
    private func setup(){
        if backView == nil {
            setupNotFlipp()
        } else {
            setupWithFlipp()
        }
    }
    
    private func setupNotFlipp(){
        guard !isSetupCompleted else { return }
        frontView.translatesAutoresizingMaskIntoConstraints = false
        if frontView.superview == nil {
           addSubview(frontView)
        }
        NSLayoutConstraint.activate([
            frontView.topAnchor.constraint(equalTo: topAnchor),
            frontView.leadingAnchor.constraint(equalTo: leadingAnchor),
            frontView.trailingAnchor.constraint(equalTo: trailingAnchor),
            frontView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }

    private func setupWithFlipp() {
        guard !isSetupCompleted, let backView = backView else { return }
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

    //MARK: - Add Gesture Recognizer
    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(flip))
        addGestureRecognizer(tap)
    }

    //MARK: - Actions
    @objc func flip() {
        guard let backView = backView else { return }
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
