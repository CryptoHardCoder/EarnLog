//
//  CustomTabbar.swift
//  EarnLog
//
//  Created by M3 pro on 09/09/2025.
//
//
import UIKit

class MiddleTabBarButton: UITabBar {
    
    var rootControllerForButton: UIViewController
    
    // MARK: - Properties
    private var tabBarWidth: CGFloat { self.bounds.width }
    private var tabBarHeight: CGFloat { self.bounds.height }
    private var centerWidth: CGFloat { self.bounds.width / 2 }
    private let addButtonDiameter: CGFloat = 68.0
    
    private var shapeLayer: CALayer? = nil
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = DSColors.appPrimary
        button.layer.cornerRadius = addButtonDiameter / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = DSColors.appPrimary.withAlphaComponent(0.9).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 10)
        button.layer.shadowRadius = 20
        button.layer.shadowOpacity = 1
        button.projectAnimationForButtons()
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var addImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "+_Icon_svg")?.withRenderingMode(.alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
        
    init(rootViewControllerForButton: UIViewController) {
        self.rootControllerForButton = rootViewControllerForButton
        super.init(frame: .zero)
        setupAddButton()
        backgroundColor = .clear
        tintColor = DSColors.appPrimary
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Overridden Methods
    override func draw(_ rect: CGRect) {
        drawTabBar()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Сначала проверяем стандартную область таб-бара
        let pointIsInside = super.point(inside: point, with: event)
        
        if !pointIsInside {
            // Проверяем, попадает ли точка в область кнопки
            let buttonFrame = addButton.frame
            if buttonFrame.contains(point) {
                return true
            }
            
            // Проверяем другие subview
            for subview in subviews {
                let pointInSubview = subview.convert(point, from: self)
                if subview.point(inside: pointInSubview, with: event) {
                    return true
                }
            }
        }
        
        return pointIsInside
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Сначала проверяем кнопку добавления
        if !clipsToBounds && !isHidden && alpha > 0 {
            let buttonFrame = addButton.frame
            if buttonFrame.contains(point) {
                return addButton.hitTest(convert(point, to: addButton), with: event)
            }
        }
        
        // Затем стандартное поведение
        return super.hitTest(point, with: event)
    }
    
    // MARK: - Private Methods
    
    private func setupAddButton() {
        addSubview(addButton)
        addButton.addSubview(addImageView)
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: topAnchor, constant: 10),
            addButton.heightAnchor.constraint(equalToConstant: addButtonDiameter),
            addButton.widthAnchor.constraint(equalToConstant: addButtonDiameter),

            addImageView.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
            addImageView.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            addImageView.widthAnchor.constraint(equalToConstant: addButtonDiameter / 2),
            addImageView.heightAnchor.constraint(equalToConstant: addButtonDiameter / 2)
        ])

    }
    
    @objc private func addButtonTapped() {
        if let parentViewController = findParentViewController() {
            let addNavigationController = UINavigationController(rootViewController: rootControllerForButton)
            addNavigationController.configureNavigationBar()
            addNavigationController.navigationBar.prefersLargeTitles = false
            addNavigationController.modalPresentationStyle = .pageSheet

            if let sheet = addNavigationController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]

                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true

//                sheet.largestUndimmedDetentIdentifier = .medium
            }
            parentViewController.present(addNavigationController, animated: true)
        } else {
            print("Parent ViewController not found!")
        }
    }

    private func findParentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    private func drawTabBar() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = shapePath()
        shapeLayer.strokeColor = DSColors.gray.cgColor
        shapeLayer.fillColor = DSColors.appBackground.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.zPosition = -1

        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }

        self.shapeLayer = shapeLayer
    }
    
    private func shapePath() -> CGPath {
        let path = UIBezierPath()
        
        let center = centerWidth
        let cutoutHeight: CGFloat = 47  // Глубина выреза (больше половины кнопки)
        
        // Начинаем слева
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Линия до начала выреза
        path.addLine(to: CGPoint(x: center - 70, y: 0))
        
        // Создаем плавный вырез с помощью кривых Безье
        let controlPoint1 = CGPoint(x: center - 40, y: 0)
        let controlPoint2 = CGPoint(x: center - 40, y: cutoutHeight)
        let midPoint = CGPoint(x: center, y: cutoutHeight)
        
        path.addCurve(to: midPoint, 
                     controlPoint1: controlPoint1, 
                     controlPoint2: controlPoint2)
        
        let controlPoint3 = CGPoint(x: center + 40, y: cutoutHeight)
        let controlPoint4 = CGPoint(x: center + 40, y: 0)

        let endPoint = CGPoint(x: center + 70, y: 0)
        
        path.addCurve(to: endPoint, 
                     controlPoint1: controlPoint3, 
                     controlPoint2: controlPoint4)
        
        // Линия до правого края
        path.addLine(to: CGPoint(x: tabBarWidth, y: 0))
        
        // Вниз и влево, замыкаем путь
        path.addLine(to: CGPoint(x: tabBarWidth, y: tabBarHeight))
        path.addLine(to: CGPoint(x: 0, y: tabBarHeight))
        path.close()
        
        return path.cgPath
    }
}
