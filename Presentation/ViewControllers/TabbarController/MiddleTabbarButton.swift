//
//  CustomTabbar.swift
//  EarnLog
//
//  Created by M3 pro on 09/09/2025.
//
//
import UIKit

class MiddleTabbarButton: UITabBar {
    
    var rootControllerForButton: UIViewController
    
    // MARK: - Properties
    
    private var tabBarWidth: CGFloat { self.bounds.width }
    private var tabBarHeight: CGFloat { self.bounds.height }
    private var centerWidth: CGFloat { self.bounds.width / 2 }
    private let addButtonDiameter: CGFloat = 68.0
    
    private var shapeLayer: CALayer? = nil
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .designPrimary
        button.layer.cornerRadius = addButtonDiameter / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = UIColor.designPrimary.withAlphaComponent(0.9).cgColor
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
        tintColor = .designPrimary
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
            addButton.widthAnchor.constraint(equalToConstant: addButtonDiameter)
        ])
        
        NSLayoutConstraint.activate([
            addImageView.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
            addImageView.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            addImageView.widthAnchor.constraint(equalToConstant: addButtonDiameter / 2),
            addImageView.heightAnchor.constraint(equalToConstant: addButtonDiameter / 2)
        ])
 
    }
    
    @objc private func addButtonTapped() {
//        customDelegate?.addButtonTapped()
        // Находим родительский ViewController
        if let parentViewController = findParentViewController() {
            
            let addNavigationController = UINavigationController(rootViewController: rootControllerForButton)
            
            // Настройка модального представления
            addNavigationController.modalPresentationStyle = .pageSheet
            
            // Показываем контроллер
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
        shapeLayer.strokeColor = UIColor.systemGray6.cgColor
        shapeLayer.fillColor = UIColor.designBackground.cgColor
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
//protocol CustomTabBarDelegate: AnyObject {
//    func addButtonTapped()
//}
//
//class CustomTabbar: UITabBar {
//    // MARK: - Properties
//    
//    weak var customDelegate: CustomTabBarDelegate?
//    
//    private var tabBarWidth: CGFloat { self.bounds.width }
//    private var tabBarHeight: CGFloat { self.bounds.height }
//    private var centerWidth: CGFloat { self.bounds.width / 2 }
//    private let circleRadius: CGFloat = 25
//    private let addButtonDiameter: CGFloat = 68.0
//    
//    private var shapeLayer: CALayer? = nil
//    
//    private lazy var addButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.backgroundColor = .designPrimary
//        button.layer.cornerRadius = addButtonDiameter / 2
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.layer.shadowColor = UIColor.designPrimary.withAlphaComponent(0.6).cgColor
//        button.layer.shadowOffset = CGSize(width: 0, height: 5)
//        button.layer.shadowRadius = 20
//        button.layer.shadowOpacity = 1
//        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    private lazy var addImageView: UIImageView = {
//       let imageView = UIImageView()
//        imageView.image = UIImage(named: "+_Icon_svg")?.withRenderingMode(.alwaysOriginal)
//        imageView.contentMode = .scaleAspectFit
//        imageView.backgroundColor = .clear
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupAddButton()
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupAddButton()
//        backgroundColor = .clear
//        tintColor = .designPrimary
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupAddButton()
//    }
//    
//    // MARK: - Overridden Methods
//    
//    override func draw(_ rect: CGRect) {
//        drawTabBar()
//    }
//    
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//           // Сначала проверяем стандартную область таб-бара
//           let pointIsInside = super.point(inside: point, with: event)
//           
//           if !pointIsInside {
//               // Проверяем, попадает ли точка в область кнопки
//               let buttonFrame = addButton.frame
//               if buttonFrame.contains(point) {
//                   return true
//               }
//               
//               // Проверяем другие subview
//               for subview in subviews {
//                   let pointInSubview = subview.convert(point, from: self)
//                   if subview.point(inside: pointInSubview, with: event) {
//                       return true
//                   }
//               }
//           }
//           
//           return pointIsInside
//       }
//       
//   override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//       // Сначала проверяем кнопку добавления
//       if !clipsToBounds && !isHidden && alpha > 0 {
//           let buttonFrame = addButton.frame
//           if buttonFrame.contains(point) {
//               return addButton.hitTest(convert(point, to: addButton), with: event)
//           }
//       }
//       
//       // Затем стандартное поведение
//       return super.hitTest(point, with: event)
//   }
//    
////    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
////        let pointIsInside = super.point(inside: point, with: event)
////        if pointIsInside == false {
////            for subview in subviews {
////                let pointInSubview = subview.convert(point, from: self)
////                if subview.point(inside: pointInSubview, with: event) {
////                    return true
////                }
////            }
////        }
////        return pointIsInside
////    }
//    
//    // MARK: - Private Methods
//    
//    private func setupAddButton() {
//        addSubview(addButton)
//        addButton.addSubview(addImageView)
//        
//        NSLayoutConstraint.activate([
//            addButton.centerXAnchor.constraint(equalTo: centerXAnchor),
//            addButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30),
//            addButton.heightAnchor.constraint(equalToConstant: addButtonDiameter),
//            addButton.widthAnchor.constraint(equalToConstant: addButtonDiameter)
//        ])
//        
//        NSLayoutConstraint.activate([
//            addImageView.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
//            addImageView.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
//            addImageView.widthAnchor.constraint(equalToConstant: addButtonDiameter / 2),
//            addImageView.heightAnchor.constraint(equalToConstant: addButtonDiameter / 2)
//        ])
//    }
//    
//    @objc private func addButtonTapped() {
//        customDelegate?.addButtonTapped()
//    }
//    
//    private func drawTabBar() {
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = shapePath()
//        shapeLayer.strokeColor = UIColor.green.cgColor
//        shapeLayer.fillColor = UIColor.white.cgColor
//        shapeLayer.lineWidth = 1.0
//        shapeLayer.zPosition = -1
//
//        if let oldShapeLayer = self.shapeLayer {
//            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
//        } else {
//            self.layer.insertSublayer(shapeLayer, at: 0)
//        }
//
//        self.shapeLayer = shapeLayer
//    }
//    
//    private func shapePath() -> CGPath {
//        let path = UIBezierPath()
//        
//        let center = centerWidth
//        let radius = circleRadius + 10
//        
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x: center - 100, y: 0))
//        
//        path.addArc(withCenter: CGPoint(x: center, y: 0),
//                    radius: radius,
//                    startAngle: .pi,
//                    endAngle: 0,
//                    clockwise: false)
//        
//        path.addLine(to: CGPoint(x: tabBarWidth, y: 0))
//        path.addLine(to: CGPoint(x: tabBarWidth, y: tabBarHeight))
//        path.addLine(to: CGPoint(x: 0, y: tabBarHeight))
//        path.close()
//        
//        return path.cgPath
//    }
//}
//import UIKit
//
//class CustomTabbar: UITabBar {
//        // MARK: - Properties
//        
//        private var tabBarWidth: CGFloat { self.bounds.width }
//        private var tabBarHeight: CGFloat { self.bounds.height }
//        private var centerWidth: CGFloat { self.bounds.width / 2 }
//        private let circleRadius: CGFloat = 40
//        
//        private var shapeLayer: CALayer? = nil
//        private var circleLayer: CALayer? = nil
//        
//        // MARK: - Overriden Methods
//        
//        override func draw(_ rect: CGRect) {
//            drawTabBar()
//            
//            
//        }
//    ///    Здесь происходит следующее:
//    ///    1. Проверяем, находится ли точка касания в границах (bounds) таб-бара (в нашем случае получаем false).
//    ///    2. Если касание произошло вне bounds таб-бара:
//    ///    2.1. Проходимся по всем subview таб-бара.
//    ///    2.2. С помощью метода convert(_:from:) находим данную точку в системе координат subview. Если нажать на круглую кнопку ровно посередине у самого верха, получим CGPoint с координатами x: 21.0, y: 0.0 (в системе координат таб-бара точка имеет координаты x: 195.0, y: -10.0, где х – центр экрана, а y – величина выступа кнопки над таб-баром).
//    ///    2.3. Если касание произошло внутри subview:
//    ///    2.3.1. Возвращаем true – subview может обработать касание.
//    ///    3. Если проход по subview не дал результата, возвращаем false – касание произошло за пределами таб-бара и всех его subview. Если касание произошло в границах таб-бара (pointIsInside == true), нам не придется пробегаться по subview таб-бара. Произойдет автоматический проход по иерархии UIResponderChain, начиная от самой "глубокой" subview.
//        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//            let pointIsInside = super.point(inside: point, with: event) // 1
//            if pointIsInside == false { // 2
//                for subview in subviews { // 2.1
//                    let pointInSubview = subview.convert(point, from: self) // 2.2
//                    if subview.point(inside: pointInSubview, with: event) { // 2.3
//                        return true // 2.3.1
//                    }
//                }
//            }
//            return pointIsInside // 3
//        }
//        
//        // MARK: - Private Methods
//        
//        private func drawTabBar() {
//            // 1
//            let shapeLayer = CAShapeLayer()
//            shapeLayer.path = shapePath()
//            shapeLayer.strokeColor = UIColor.green.cgColor
//            shapeLayer.fillColor = UIColor.white.cgColor
//            shapeLayer.lineWidth = 1.0
//            shapeLayer.zPosition = -1
//
//            // 2
////            let circleLayer = CAShapeLayer()
////            circleLayer.path = circlePath()
////            circleLayer.strokeColor = UIColor.red.cgColor
////            circleLayer.fillColor = UIColor.clear.cgColor
////            circleLayer.lineWidth = 1.0
////            
//            // 3
//            if let oldShapeLayer = self.shapeLayer {
//                self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
//            } else {
//                self.layer.insertSublayer(shapeLayer, at: 0)
//            }
//            
////            if let oldCircleLayer = self.circleLayer {
////                self.layer.replaceSublayer(oldCircleLayer, with: circleLayer)
////            } else {
////                self.layer.insertSublayer(circleLayer, at: 1)
////            }
//
//            // 4
//            self.shapeLayer = shapeLayer
////            self.circleLayer = circleLayer
//        }
//        
//    private func shapePath() -> CGPath {
//        let path = UIBezierPath()
//        
//        // ширина каждого таба
////        let widthForTabBarItems = tabBarWidth / 5
//        
//        // центр таббара
//        let center = centerWidth
//        let radius = circleRadius + 10 // можно чуть больше, чем кнопка
//        
//        // 1. старт слева
//        path.move(to: CGPoint(x: 0, y: 0))
//        
//        // 2. линия до начала выреза
//        path.addLine(to: CGPoint(x: center - radius * 2, y: 0))
//        
//        // 3. дуга (полукруг вверх)
//        path.addArc(withCenter: CGPoint(x: center, y: 0),
//                    radius: radius,
//                    startAngle: .pi,          // слева направо
//                    endAngle: 0,
//                    clockwise: false)        // рисуем вверх
//        
//        // 4. линия до правого края
//        path.addLine(to: CGPoint(x: tabBarWidth, y: 0))
//        
//        // 5. вниз
//        path.addLine(to: CGPoint(x: tabBarWidth, y: tabBarHeight))
//        
//        // 6. влево
//        path.addLine(to: CGPoint(x: 0, y: tabBarHeight))
//        
//        // 7. закрыть путь
//        path.close()
//        
//        return path.cgPath
//    }
////        
////        private func circlePath() -> CGPath {
////            let path = UIBezierPath() // 1
////            path.addArc(withCenter: CGPoint(x: centerWidth, y: 0), // 2
////                        radius: circleRadius, // 3
////                        startAngle: /*180 * */.pi, /*/ 180,*/ // 4
////                        endAngle: .pi * 2, /** 180 / .pi,*/ // 5
////                        clockwise: false)  // 6
////            return path.cgPath // 7
////        }
//    
//
//    
//
//}
