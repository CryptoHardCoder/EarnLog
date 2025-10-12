//import UIKit
//
//struct PieChartData: Equatable {
//    let name: String
//    let value: Double
//    let color: UIColor
//}
//
//class PieChartView: UIView {
//    
//    private var data: [PieChartData] = []
//    private let gapWidth: CGFloat = 6.0 // Ширина промежутка в пикселях
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = UIColor.clear
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        backgroundColor = UIColor.clear
//    }
//    
//    func setData(_ data: [PieChartData]) {
//        self.data = data
//        // Удаляем старые слои
//        layer.sublayers?.removeAll()
//        createChart()
//    }
//    
//    private func createChart() {
//        guard !data.isEmpty else { return }
//        
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let radius = min(bounds.width, bounds.height) / 2 - 30
//        let total = data.reduce(0) { $0 + $1.value }
//        
//        // Вычисляем угловую ширину промежутков
//        let gapAngle = gapWidth / radius
//        let totalGapsAngle = CGFloat(data.count) * gapAngle
//        let usableAngle = 2 * .pi - totalGapsAngle
//        
//        var currentAngle: CGFloat = -.pi / 2 // Начинаем сверху
//        
//        for (index, item) in data.enumerated() {
//            let sectorAngle = CGFloat(item.value / total) * usableAngle
//            let midAngle = currentAngle + sectorAngle / 2
//            
//            // Смещаем каждый сектор от центра для создания промежутков
//            let offsetDistance = gapWidth / 2
//            let offsetCenter = CGPoint(
//                x: center.x + cos(midAngle) * offsetDistance,
//                y: center.y + sin(midAngle) * offsetDistance
//            )
//            
//            let sectorLayer = createSectorLayer(
//                center: offsetCenter,
//                radius: radius,
//                startAngle: currentAngle,
//                endAngle: currentAngle + sectorAngle,
//                color: item.color
//            )
//            
//            layer.addSublayer(sectorLayer)
//            currentAngle += sectorAngle + gapAngle
//        }
//    }
//    
//    private func createSectorLayer(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, color: UIColor) -> CAShapeLayer {
//        let sectorLayer = CAShapeLayer()
//        
//        let path = UIBezierPath()
//        path.move(to: center)
//        path.addArc(withCenter: center, radius: radius, 
//                   startAngle: startAngle, endAngle: endAngle, clockwise: true)
//        path.close()
//        
//        sectorLayer.path = path.cgPath
//        sectorLayer.fillColor = color.cgColor
//        
//        // Добавляем тень для лучшего визуального разделения
//        sectorLayer.shadowColor = UIColor.black.cgColor
//        sectorLayer.shadowOffset = CGSize(width: 0, height: 2)
//        sectorLayer.shadowOpacity = 0.7
//        sectorLayer.shadowRadius = 4
//        
//        return sectorLayer
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        if !data.isEmpty {
//            setData(data) // Пересоздаем при изменении размера
//        }
//    }
//}
//
//// MARK: - Более точная версия с настоящими параллельными промежутками
//
//class PrecisePieChartView: UIView {
//    
//    private var data: [PieChartData] = []
//    private let gapWidth: CGFloat = 8.0
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = UIColor.clear
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        backgroundColor = UIColor.clear
//    }
//    
//    func setData(_ data: [PieChartData]) {
//        self.data = data
//        setNeedsDisplay()
//    }
//    
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext(), !data.isEmpty else { return }
//        
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius = min(rect.width, rect.height) / 2 - 20
//        let total = data.reduce(0) { $0 + $1.value }
//        
//        // Рисуем белый круг как фон для создания промежутков
//        context.setFillColor(UIColor.systemBackground.cgColor)
//        context.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, 
//                                      width: radius * 2, height: radius * 2))
//        
//        var currentAngle: CGFloat = -.pi / 2
//        let angleStep = 2 * .pi / CGFloat(data.count)
//        
//        for item in data {
//            let sectorAngle = CGFloat(item.value / total) * (2 * .pi)
//            
//            drawSectorWithPreciseGaps(
//                context: context,
//                center: center,
//                radius: radius,
//                startAngle: currentAngle,
//                sectorAngle: sectorAngle,
//                color: item.color,
//                gapWidth: gapWidth
//            )
//            
//            currentAngle += angleStep
//        }
//    }
//    
//    private func drawSectorWithPreciseGaps(context: CGContext, center: CGPoint, radius: CGFloat, 
//                                          startAngle: CGFloat, sectorAngle: CGFloat, 
//                                          color: UIColor, gapWidth: CGFloat) {
//        
//        context.saveGState()
//        
//        // Создаем сектор
//        context.beginPath()
//        context.move(to: center)
//        context.addArc(center: center, radius: radius, 
//                      startAngle: startAngle, endAngle: startAngle + sectorAngle, 
//                      clockwise: false)
//        context.closePath()
//        
//        context.setFillColor(color.cgColor)
//        context.fillPath()
//        
//        // Рисуем белые линии для промежутков
//        let lineWidth = gapWidth
//        context.setStrokeColor(UIColor.systemBackground.cgColor)
//        context.setLineWidth(lineWidth)
//        context.setLineCap(.round)
//        
//        // Линия в начале сектора
//        let startPoint = CGPoint(x: center.x + cos(startAngle) * radius,
//                               y: center.y + sin(startAngle) * radius)
//        context.beginPath()
//        context.move(to: center)
//        context.addLine(to: startPoint)
//        context.strokePath()
//        
//        // Линия в конце сектора
//        let endPoint = CGPoint(x: center.x + cos(startAngle + sectorAngle) * radius,
//                             y: center.y + sin(startAngle + sectorAngle) * radius)
//        context.beginPath()
//        context.move(to: center)
//        context.addLine(to: endPoint)
//        context.strokePath()
//        
//        context.restoreGState()
//    }
//}
//
//// MARK: - Простое и работающее решение
//
//class SimplePieChartView: UIView {
//    
//    private var data: [PieChartData] = []
//    private let gapWidth: CGFloat = 8.0
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = UIColor.clear
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        backgroundColor = UIColor.clear
//    }
//    
//    func setData(_ data: [PieChartData]) {
//        self.data = data
//        setNeedsDisplay()
//    }
//    
//    override func draw(_ rect: CGRect) {
//        guard !data.isEmpty else { return }
//        
//        let context = UIGraphicsGetCurrentContext()!
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let outerRadius = min(rect.width, rect.height) / 2 - 20
//        let innerRadius: CGFloat = 60 // Создаем кольцо вместо полного круга
//        
//        let total = data.reduce(0) { $0 + $1.value }
//        
//        // Рисуем фон
//        context.setFillColor(UIColor.systemBackground.cgColor)
//        context.fillEllipse(in: rect)
//        
//        var currentAngle: CGFloat = -.pi / 2
//        
//        for item in data {
//            let sectorAngle = CGFloat(item.value / total) * 2 * .pi
//            let endAngle = currentAngle + sectorAngle
//            
//            // Уменьшаем угол сектора для создания промежутков
//            let gapAngle = gapWidth / outerRadius
//            let adjustedEndAngle = endAngle - gapAngle
//            
//            if adjustedEndAngle > currentAngle {
//                // Рисуем кольцевой сектор
//                let path = UIBezierPath()
//                path.move(to: CGPoint(x: center.x + cos(currentAngle) * innerRadius,
//                                    y: center.y + sin(currentAngle) * innerRadius))
//                
//                // Внешняя дуга
//                path.addLine(to: CGPoint(x: center.x + cos(currentAngle) * outerRadius,
//                                       y: center.y + sin(currentAngle) * outerRadius))
//                path.addArc(withCenter: center, radius: outerRadius, 
//                           startAngle: currentAngle, endAngle: adjustedEndAngle, clockwise: true)
//                
//                // Внутренняя дуга (обратно)
//                path.addLine(to: CGPoint(x: center.x + (cos(adjustedEndAngle) * innerRadius),
//                                       y: center.y + sin(adjustedEndAngle) * innerRadius))
//                path.addArc(withCenter: center, radius: innerRadius, 
//                           startAngle: adjustedEndAngle, endAngle: currentAngle, clockwise: false)
//                path.close()
//                
//                item.color.setFill()
//                path.fill()
//            }
//            
//            currentAngle = endAngle
//        }
//        
//        // Рисуем центральный круг
//        context.setFillColor(UIColor.systemBackground.cgColor)
//        context.fillEllipse(in: CGRect(x: center.x - innerRadius, y: center.y - innerRadius,
//                                      width: innerRadius * 2, height: innerRadius * 2))
//    }
//}
//
//// MARK: - Использование
//
//class ViewController: UIViewController {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupPieChart()
//    }
//    
//    private func setupPieChart() {
//        let chartData = [
//            PieChartData(name: "Warszawa26", value: 1400, color: UIColor.systemRed),
//            PieChartData(name: "Fenix", value: 1350, color: UIColor.systemBlue),
//            PieChartData(name: "Основная", value: 850, color: UIColor.systemGreen)
//        ]
//        
//        // Используем простое решение
//        let pieChartView = SimplePieChartView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
//        pieChartView.center = view.center
//        pieChartView.setData(chartData)
//        
//        view.backgroundColor = UIColor.systemBackground
//        view.addSubview(pieChartView)
//        
//        setupLegend(with: chartData, below: pieChartView)
//    }
//    
//    private func setupLegend(with data: [PieChartData], below chartView: UIView) {
//        let legendStackView = UIStackView()
//        legendStackView.axis = .vertical
//        legendStackView.spacing = 12
//        legendStackView.alignment = .leading
//        
//        for item in data {
//            let legendItemView = createLegendItem(data: item)
//            legendStackView.addArrangedSubview(legendItemView)
//        }
//        
//        view.addSubview(legendStackView)
//        legendStackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            legendStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            legendStackView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 30)
//        ])
//    }
//    
//    private func createLegendItem(data: PieChartData) -> UIView {
//        let containerView = UIView()
//        
//        let colorView = UIView()
//        colorView.backgroundColor = data.color
//        colorView.layer.cornerRadius = 8
//        colorView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let label = UILabel()
//        label.text = "\(data.name): \(Int(data.value))"
//        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        containerView.addSubview(colorView)
//        containerView.addSubview(label)
//        
//        NSLayoutConstraint.activate([
//            colorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//            colorView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            colorView.widthAnchor.constraint(equalToConstant: 16),
//            colorView.heightAnchor.constraint(equalToConstant: 16),
//            
//            label.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 12),
//            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            label.topAnchor.constraint(equalTo: containerView.topAnchor),
//            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
//        ])
//        
//        return containerView
//    }
//}
import SwiftUI
import Charts

struct PieChartData: Identifiable {
    var id = UUID()
    var name: String
    var value: Double
}

struct PieChartSwiftUI: View {
    var data: [PieChartData] = []
    
    var body: some View {
        Chart(data) { item in
            if #available(iOS 17.0, *) {
                SectorMark(
                    angle: .value("Value", item.value),
                    innerRadius: .ratio(0.3),
                    angularInset: 5 // gap между секторами
                )
                .foregroundStyle(by: .value("Name", item.name))
                .cornerRadius(4, style: .continuous)
            } else {
                // Fallback on earlier versions
            }
        }
        .chartLegend(.hidden)
        .aspectRatio(1, contentMode: .fit) 
        .padding()
    }
}
class PieChartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Данные
        let stats = [
            PieChartData(name: "Warszawa26", value: 1400),
            PieChartData(name: "Fenix", value: 1350),
            PieChartData(name: "Основная", value: 850),
            PieChartData(name: "Main", value: 2000)
        ]
        
        // Создаем SwiftUI view
        let pieChartSwiftUIView = PieChartSwiftUI(data: stats)
        
        // Встраиваем через UIHostingController
        let hostingController = UIHostingController(rootView: pieChartSwiftUIView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            hostingController.view.widthAnchor.constraint(equalToConstant: 250),
            hostingController.view.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
}


@available(iOS 17.0, *)
#Preview {
    PieChartViewController()
    
}

// Используем простое решение
//        let pieChartView = SimplePieChartView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
//        let pieChartView = PieChartView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))

//// MARK: - Более продвинутая версия с анимацией
//
//class AnimatedPieChartView: PieChartView {
//    
//    private var displayLink: CADisplayLink?
//    private var animationProgress: CGFloat = 0
//    private var isAnimating = false
//    
//    override func setData(_ data: [PieChartData]) {
//        super.setData(data)
//        startAnimation()
//    }
//    
//    private func startAnimation() {
//        animationProgress = 0
//        isAnimating = true
//        
//        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
//        displayLink?.add(to: .current, forMode: .default)
//    }
//    
//    @objc private func updateAnimation() {
//        animationProgress += 0.02
//        
//        if animationProgress >= 1.0 {
//            animationProgress = 1.0
//            stopAnimation()
//        }
//        
//        setNeedsDisplay()
//    }
//    
//    private func stopAnimation() {
//        isAnimating = false
//        displayLink?.invalidate()
//        displayLink = nil
//    }
//    
//    override func draw(_ rect: CGRect) {
//        guard !data.isEmpty else { return }
//        
//        let context = UIGraphicsGetCurrentContext()
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius = min(rect.width, rect.height) / 2 - 20
//        
//        let total = data.reduce(0) { $0 + $1.value }
//        let totalGapAngle = CGFloat(data.count) * (gapWidth / radius)
//        let availableAngle = 2 * .pi - totalGapAngle
//        
//        var currentAngle: CGFloat = -.pi / 2
//        
//        for (index, item) in data.enumerated() {
//            let sectorAngle = CGFloat(item.value / total) * availableAngle * animationProgress
//            let endAngle = currentAngle + sectorAngle
//            
//            if sectorAngle > 0 {
//                let path = createSeparatedArcPath(
//                    center: center,
//                    radius: radius,
//                    startAngle: currentAngle,
//                    endAngle: endAngle,
//                    gapWidth: gapWidth
//                )
//                
//                context?.setFillColor(item.color.cgColor)
//                context?.addPath(path.cgPath)
//                context?.fillPath()
//            }
//            
//            currentAngle = endAngle + (gapWidth / radius)
//        }
//    }
//}
