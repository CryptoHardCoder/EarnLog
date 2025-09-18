

import UIKit

// MARK: - Ячейка таблицы

class IncomeTableViewCell: UITableViewCell, MemoryTrackable {
    static let reuseIdentifier = "IncomeTableViewCell"
    private let dateLabel = UILabel()
    private let jobIdentityLabel = UILabel()
    private let priceLabel = UILabel()
    private let checkmarkButton = UIButton()
    private let statusPaymentLabel = UILabel()
    private let sourceLabel = UILabel()
    
    // Constraints для разных режимов
    private var checkmarkButtonConstraints: [NSLayoutConstraint] = []
    private var normalModeConstraints: [NSLayoutConstraint] = []
    private var selectionModeConstraints: [NSLayoutConstraint] = []
    
    var onCheckmarkTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        trackCreation() //для анализа на memory leaks
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        backgroundColor = .itemsBackground
        layer.cornerRadius = 12
        
        checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkmarkButton.addTarget(self, action: #selector(checkmarkTapped), for: .touchUpInside)
        
        dateLabel.textColor = .systemGray
        dateLabel.font = .systemFont(ofSize: 14)
        
        jobIdentityLabel.textColor = .label
        jobIdentityLabel.font = .systemFont(ofSize: 16, weight: .medium)
        jobIdentityLabel.lineBreakMode = .byTruncatingTail
        jobIdentityLabel.numberOfLines = 1
        jobIdentityLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        sourceLabel.textColor = .label.withAlphaComponent(0.5)
        sourceLabel.font = .systemFont(ofSize: 16, weight: .medium)
        sourceLabel.textAlignment = .right
        sourceLabel.lineBreakMode = .byTruncatingTail
        sourceLabel.numberOfLines = 1
        sourceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        statusPaymentLabel.font = .systemFont(ofSize: 12)
        
        priceLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        priceLabel.textAlignment = .right
        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        [statusPaymentLabel, checkmarkButton, dateLabel, jobIdentityLabel, sourceLabel, priceLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        // Базовые constraints (всегда активные)
        NSLayoutConstraint.activate([
            // dateLabel
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -16),
            
            // sourceLabel
            sourceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
//            sourceLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            sourceLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            sourceLabel.leadingAnchor.constraint(equalTo: jobIdentityLabel.trailingAnchor, constant: 5),
//            sourceLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -8),
//            sourceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // priceLabel
            priceLabel.centerYAnchor.constraint(equalTo: jobIdentityLabel.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceLabel.widthAnchor.constraint(equalToConstant: 80),
            
            // statusPaymentLabel
            statusPaymentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            statusPaymentLabel.widthAnchor.constraint(equalToConstant: 100),
        ])
        
        // Constraints для checkmarkButton (только для режима выбора)
        checkmarkButtonConstraints = [
            checkmarkButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            checkmarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 30),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 30)
        ]
        
        // Constraints для ОБЫЧНОГО режима (без кнопки)
        normalModeConstraints = [
            jobIdentityLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            jobIdentityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            carLabel.trailingAnchor.constraint(equalTo: sourceLabel.leadingAnchor, constant: -8),
//            sourceLabel.centerYAnchor.constraint(equalTo: carLabel.centerYAnchor),
//            sourceLabel.leadingAnchor.constraint(equalTo: carLabel.trailingAnchor, constant: 5),
            
            statusPaymentLabel.topAnchor.constraint(equalTo: jobIdentityLabel.bottomAnchor, constant: 2),
            statusPaymentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        ]
        
        // Constraints для РЕЖИМА ВЫБОРА (с кнопкой)
        selectionModeConstraints = [
            jobIdentityLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            jobIdentityLabel.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor, constant: 12),
            
//            sourceLabel.centerYAnchor.constraint(equalTo: carLabel.centerYAnchor),
//            sourceLabel.leadingAnchor.constraint(equalTo: carLabel.trailingAnchor, constant: 5),
            
            statusPaymentLabel.topAnchor.constraint(equalTo: jobIdentityLabel.bottomAnchor, constant: 2),
            statusPaymentLabel.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor, constant: 12),
        ]
        
        // По умолчанию включаем обычный режим и прячем кнопку
        checkmarkButton.isHidden = true
        NSLayoutConstraint.activate(normalModeConstraints)
    }
    
    @objc private func checkmarkTapped() {
        onCheckmarkTapped?()
    }
    
    // Добавляем переменную для отслеживания текущего режима
    private var currentSelectionMode: Bool?  // nil означает что режим еще не был установлен
    
    func configure(with item: IncomeEntry, isSelectionMode: Bool = false, isSelected: Bool = false){
    
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .none
        
        dateLabel.text = dateformatter.string(from: item.date)
        jobIdentityLabel.text = item.car
        sourceLabel.text = item.source.displayName
//        print(sourceLabel.text)
        priceLabel.text = String(format: "%.0f zł", (item.price))
        
        // Настройка статуса оплаты
        if item.isPaid {
            statusPaymentLabel.textColor = .systemGreen
            statusPaymentLabel.text = "paid_for_cell".localized
            priceLabel.textColor = .systemGreen.withAlphaComponent(0.8)
            jobIdentityLabel.textColor = .systemGray
        } else {
            statusPaymentLabel.text = "unPaid_for_cell".localized
            statusPaymentLabel.textColor = .systemOrange
            priceLabel.textColor = .systemBlue
            jobIdentityLabel.textColor = .label
        }
        
        // Переключаем layout если режим изменился ИЛИ устанавливается впервые
        if currentSelectionMode != isSelectionMode {
            updateLayoutForSelectionMode(isSelectionMode, isSelected: isSelected)
            currentSelectionMode = isSelectionMode
        } else {
            // Если режим не изменился, только обновляем состояние кнопки
            if isSelectionMode {
                checkmarkButton.isSelected = isSelected
                checkmarkButton.tintColor = isSelected ? .systemBlue : .systemGray
            }
        }
    }
    
    private func updateLayoutForSelectionMode(_ isSelectionMode: Bool, isSelected: Bool) {
        if isSelectionMode {
            // РЕЖИМ ВЫБОРА: показываем кнопку и меняем constraints
            
            // Деактивируем обычные constraints
            NSLayoutConstraint.deactivate(normalModeConstraints)
            
            // Показываем кнопку
            checkmarkButton.isHidden = false
            checkmarkButton.isSelected = isSelected
            checkmarkButton.tintColor = isSelected ? .systemBlue : .systemGray
            
            // Активируем constraints для режима выбора
            NSLayoutConstraint.activate(checkmarkButtonConstraints)
            NSLayoutConstraint.activate(selectionModeConstraints)
            
        } else {
            // ОБЫЧНЫЙ РЕЖИМ: прячем кнопку и возвращаем constraints
            
            // Деактивируем constraints режима выбора
            NSLayoutConstraint.deactivate(checkmarkButtonConstraints)
            NSLayoutConstraint.deactivate(selectionModeConstraints)
            
            // Прячем кнопку
            checkmarkButton.isHidden = true
            
            // Активируем обычные constraints
            NSLayoutConstraint.activate(normalModeConstraints)
        }
        
        // НЕ вызываем setNeedsLayout при каждом обновлении
        // setNeedsLayout() - убираем эту строку
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        trackDeallocation()
    }
    
}

@available(iOS 17.0, *)
#Preview {
    MainViewController()
    
}



// MARK: - Ячейка таблицы (сырой дизайн)

//class IncomeTableViewCell: UITableViewCell, MemoryTrackable {
//    static let reuseIdentifier = "IncomeTableViewCell"
//    
//    private let dateLabel = UILabel()
//    private let carLabel = UILabel()
//    private let priceLabel = UILabel()
//    private let checkmarkButton = UIButton()
//    private let statusPaymentLabel = UILabel()
//    private let sourceLabel = UILabel()
//    
//    // Constraints для разных режимов
//    private var checkmarkButtonConstraints: [NSLayoutConstraint] = []
//    private var normalModeConstraints: [NSLayoutConstraint] = []
//    private var selectionModeConstraints: [NSLayoutConstraint] = []
//    
//    var onCheckmarkTapped: (() -> Void)?
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        trackCreation() //для анализа на memory leaks
//        setupViews()
//        setupConstraints()
//    }
//    
//    private func setupViews() {
//        checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
//        checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
//        checkmarkButton.addTarget(self, action: #selector(checkmarkTapped), for: .touchUpInside)
//        
//        dateLabel.textColor = .systemGray
//        dateLabel.font = .systemFont(ofSize: 14)
//        
//        carLabel.textColor = .label
//        carLabel.font = .systemFont(ofSize: 16, weight: .medium)
//        carLabel.lineBreakMode = .byTruncatingTail
//        carLabel.numberOfLines = 1
//        carLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        
//        sourceLabel.textColor = .label.withAlphaComponent(0.5)
//        sourceLabel.font = .systemFont(ofSize: 16, weight: .medium)
//        sourceLabel.textAlignment = .right
//        sourceLabel.lineBreakMode = .byTruncatingTail
//        sourceLabel.numberOfLines = 1
//        sourceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        
//        statusPaymentLabel.font = .systemFont(ofSize: 12)
//        
//        priceLabel.font = .systemFont(ofSize: 16, weight: .semibold)
//        priceLabel.textAlignment = .right
//        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
//        priceLabel.setContentHuggingPriority(.required, for: .horizontal)
//        
//        [statusPaymentLabel, checkmarkButton, dateLabel, carLabel, sourceLabel, priceLabel].forEach {
//            contentView.addSubview($0)
//            $0.translatesAutoresizingMaskIntoConstraints = false
//        }
//    }
//    
//    private func setupConstraints() {
//        // Базовые constraints (всегда активные)
//        NSLayoutConstraint.activate([
//            // dateLabel
//            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
//            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            dateLabel.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -16),
//            
//            // sourceLabel
//            sourceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
////            sourceLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            sourceLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
//            sourceLabel.leadingAnchor.constraint(equalTo: carLabel.trailingAnchor, constant: 5),
////            sourceLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -8),
////            sourceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            
//            // priceLabel
//            priceLabel.centerYAnchor.constraint(equalTo: carLabel.centerYAnchor),
//            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            priceLabel.widthAnchor.constraint(equalToConstant: 80),
//            
//            // statusPaymentLabel
//            statusPaymentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            statusPaymentLabel.widthAnchor.constraint(equalToConstant: 100),
//        ])
//        
//        // Constraints для checkmarkButton (только для режима выбора)
//        checkmarkButtonConstraints = [
//            checkmarkButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
//            checkmarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            checkmarkButton.widthAnchor.constraint(equalToConstant: 30),
//            checkmarkButton.heightAnchor.constraint(equalToConstant: 30)
//        ]
//        
//        // Constraints для ОБЫЧНОГО режима (без кнопки)
//        normalModeConstraints = [
//            carLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
//            carLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
////            carLabel.trailingAnchor.constraint(equalTo: sourceLabel.leadingAnchor, constant: -8),
////            sourceLabel.centerYAnchor.constraint(equalTo: carLabel.centerYAnchor),
////            sourceLabel.leadingAnchor.constraint(equalTo: carLabel.trailingAnchor, constant: 5),
//            
//            statusPaymentLabel.topAnchor.constraint(equalTo: carLabel.bottomAnchor, constant: 2),
//            statusPaymentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//        ]
//        
//        // Constraints для РЕЖИМА ВЫБОРА (с кнопкой)
//        selectionModeConstraints = [
//            carLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
//            carLabel.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor, constant: 12),
//            
////            sourceLabel.centerYAnchor.constraint(equalTo: carLabel.centerYAnchor),
////            sourceLabel.leadingAnchor.constraint(equalTo: carLabel.trailingAnchor, constant: 5),
//            
//            statusPaymentLabel.topAnchor.constraint(equalTo: carLabel.bottomAnchor, constant: 2),
//            statusPaymentLabel.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor, constant: 12),
//        ]
//        
//        // По умолчанию включаем обычный режим и прячем кнопку
//        checkmarkButton.isHidden = true
//        NSLayoutConstraint.activate(normalModeConstraints)
//    }
//    
//    @objc private func checkmarkTapped() {
//        onCheckmarkTapped?()
//    }
//    
//    // Добавляем переменную для отслеживания текущего режима
//    private var currentSelectionMode: Bool?  // nil означает что режим еще не был установлен
//    
//    func configure(with item: IncomeEntry, isSelectionMode: Bool = false, isSelected: Bool = false){
//    
//        let dateformatter = DateFormatter()
//        dateformatter.dateStyle = .medium
//        dateformatter.timeStyle = .none
//        
//        dateLabel.text = dateformatter.string(from: item.date)
//        carLabel.text = item.car
//        sourceLabel.text = item.source.displayName
////        print(sourceLabel.text)
//        priceLabel.text = String(format: "%.0f zł", (item.price))
//        
//        // Настройка статуса оплаты
//        if item.isPaid {
//            statusPaymentLabel.textColor = .systemGreen
//            statusPaymentLabel.text = "paid_for_cell".localized
//            priceLabel.textColor = .systemGreen.withAlphaComponent(0.8)
//            carLabel.textColor = .systemGray
//        } else {
//            statusPaymentLabel.text = "unPaid_for_cell".localized
//            statusPaymentLabel.textColor = .systemOrange
//            priceLabel.textColor = .systemBlue
//            carLabel.textColor = .label
//        }
//        
//        // Переключаем layout если режим изменился ИЛИ устанавливается впервые
//        if currentSelectionMode != isSelectionMode {
//            updateLayoutForSelectionMode(isSelectionMode, isSelected: isSelected)
//            currentSelectionMode = isSelectionMode
//        } else {
//            // Если режим не изменился, только обновляем состояние кнопки
//            if isSelectionMode {
//                checkmarkButton.isSelected = isSelected
//                checkmarkButton.tintColor = isSelected ? .systemBlue : .systemGray
//            }
//        }
//    }
//    
//    private func updateLayoutForSelectionMode(_ isSelectionMode: Bool, isSelected: Bool) {
//        if isSelectionMode {
//            // РЕЖИМ ВЫБОРА: показываем кнопку и меняем constraints
//            
//            // Деактивируем обычные constraints
//            NSLayoutConstraint.deactivate(normalModeConstraints)
//            
//            // Показываем кнопку
//            checkmarkButton.isHidden = false
//            checkmarkButton.isSelected = isSelected
//            checkmarkButton.tintColor = isSelected ? .systemBlue : .systemGray
//            
//            // Активируем constraints для режима выбора
//            NSLayoutConstraint.activate(checkmarkButtonConstraints)
//            NSLayoutConstraint.activate(selectionModeConstraints)
//            
//        } else {
//            // ОБЫЧНЫЙ РЕЖИМ: прячем кнопку и возвращаем constraints
//            
//            // Деактивируем constraints режима выбора
//            NSLayoutConstraint.deactivate(checkmarkButtonConstraints)
//            NSLayoutConstraint.deactivate(selectionModeConstraints)
//            
//            // Прячем кнопку
//            checkmarkButton.isHidden = true
//            
//            // Активируем обычные constraints
//            NSLayoutConstraint.activate(normalModeConstraints)
//        }
//        
//        // НЕ вызываем setNeedsLayout при каждом обновлении
//        // setNeedsLayout() - убираем эту строку
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    deinit {
//        trackDeallocation()
//    }
//    
//}
