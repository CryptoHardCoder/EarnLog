//
//  DatePickerSection.swift
//  EarnLog
//
//  Created by M3 pro on 18/10/2025.
//
import UIKit


// MARK: - DatePickerSection
final class DatePickerSection: UIView {
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        sv.layer.cornerRadius = 10
        sv.layer.borderWidth = 1
        sv.layer.borderColor = UIColor.designBlack.withAlphaComponent(0.6).cgColor
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let title: UILabel?
    private let dateTextField: UITextField
    private let datePicker: UIDatePicker
    private let onDateSelected: () -> Void
    
    private var isExpanded = false
    private var pickerHeightConstraint: NSLayoutConstraint!
    
    init(title: UILabel?, dateTextField: UITextField, datePicker: UIDatePicker, onDateSelected: @escaping () -> Void) {
        self.title = title
        self.dateTextField = dateTextField
        self.datePicker = datePicker
        self.onDateSelected = onDateSelected
        super.init(frame: .zero)
        if title != nil {
            setupUI(withHeader: true)
        } else {
            setupUI(withHeader: false)
        }
        
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(withHeader label: Bool) {
        stackView.addArrangedSubview(dateTextField)
        stackView.addArrangedSubview(datePicker)
        
        datePicker.alpha = 0
        pickerHeightConstraint = datePicker.heightAnchor.constraint(equalToConstant: 0)
        pickerHeightConstraint.isActive = true
        if label, let title = title {
            addSubview(title)
            addSubview(stackView)
            NSLayoutConstraint.activate([
                title.topAnchor.constraint(equalTo: topAnchor),
                title.leadingAnchor.constraint(equalTo: leadingAnchor),
                title.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -8),

                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        } else {
            addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(togglePicker))
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTapAction))
        dateTextField.addGestureRecognizer(tapGesture)
        dateTextField.addGestureRecognizer(longTapGesture)
        
        
        let datePickerTapGesture = UITapGestureRecognizer(target: self, action: #selector(dateChanged))
        datePickerTapGesture.cancelsTouchesInView = false // Важно! Позволяет работать и gesture и самому picker
        datePickerTapGesture.numberOfTapsRequired = 2
        datePicker.addGestureRecognizer(datePickerTapGesture)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    @objc private func togglePicker() {
        isExpanded.toggle()
        pickerHeightConstraint.constant = isExpanded ? 330 : 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            self.datePicker.alpha = self.isExpanded ? 1 : 0
            // Анимируем весь stackView и его родителя
            self.stackView.layoutIfNeeded()
            self.superview?.superview?.layoutIfNeeded() // ScrollView's contentStackView
        }
    }
    
    @objc private func longTapAction(){
        
    }
    
    @objc private func dateChanged() {
        onDateSelected()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            
            self.isExpanded = false
            self.pickerHeightConstraint.constant = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                self.datePicker.alpha = 0
                self.stackView.layoutIfNeeded()
                self.superview?.superview?.layoutIfNeeded()
            }
        }
    }

}
