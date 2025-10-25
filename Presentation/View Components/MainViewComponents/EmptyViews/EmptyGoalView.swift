//
//  EmptyView.swift
//  EarnLog
//
//  Created by M3 pro on 19/10/2025.
//

import UIKit

final class EmptyGoalView: UIView {
    private let imageView = UIImageView()
    private let setGoalTitle = UILabel()
    private let setGoalButton = UIButton()
    
    init(){
        super.init(frame: .zero)
        setupUI()
        print("EmptyGoalView inited")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        setupImageView()
        setupTitle()
        setupButton()
    }
    
    private func setupImageView(){
        
        imageView.image = .notFined
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40)
        ])
    }
    
    private func setupTitle(){
        
        setGoalTitle.text = "You didn’t Set your monthly Goal"
        setGoalTitle.textColor = .designBlack
        setGoalTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        setGoalTitle.translatesAutoresizingMaskIntoConstraints = false
        setGoalTitle.sizeToFit()
        addSubview(setGoalTitle)
        NSLayoutConstraint.activate([
            setGoalTitle.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            setGoalTitle.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func setupButton(){
        
        setGoalButton.setTitle("Set Your Mothly Goal", for: .normal)
        setGoalButton.layer.cornerRadius = 10
        setGoalButton.tintColor = .designBlack
        setGoalButton.backgroundColor = .buttonDefault
        setGoalButton.setTitleColor(.alwaysWhite, for: .normal)
        setGoalButton.translatesAutoresizingMaskIntoConstraints = false
        setGoalButton.projectAnimationForButtons()
        setGoalButton.addTarget(self, action: #selector(setGoalTapped), for: .touchUpInside)
        addSubview(setGoalButton)
        NSLayoutConstraint.activate([
            setGoalButton.topAnchor.constraint(equalTo: setGoalTitle.bottomAnchor, constant: 10),
            setGoalButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            setGoalButton.widthAnchor.constraint(equalToConstant: 263),
            setGoalButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    @objc
    private func setGoalTapped(){
        print("Написать тело функции: View Components/GoalAndStatsCard/EmptyView")
    }
    
    deinit {
        print("EmptyGoalView deinited")
    }
}

@available(iOS 17.0, *)
#Preview {
    EmptyGoalView()
    
}
