
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
            SectorMark(
                angle: .value("Value", item.value),
                innerRadius: .ratio(0.3),
                angularInset: 5 // gap между секторами
            )
            .foregroundStyle(by: .value("Name", item.name))
            .cornerRadius(4, style: .continuous)
            
        }
        .chartLegend(.hidden)
        .aspectRatio(1, contentMode: .fit) 
        .padding()
    }
}
//class PieChartViewController: UIViewController {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .clear
//
//        // Данные
//        let stats = [
//            PieChartData(name: "Warszawa26", value: 1400),
//            PieChartData(name: "Fenix", value: 1350),
//            PieChartData(name: "Основная", value: 850),
//            PieChartData(name: "Main", value: 2000)
//        ]
//        
//        // Создаем SwiftUI view
//        let pieChartSwiftUIView = PieChartSwiftUI(data: stats)
//        
//        // Встраиваем через UIHostingController
//        let hostingController = UIHostingController(rootView: pieChartSwiftUIView)
//        addChild(hostingController)
//        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(hostingController.view)
//        hostingController.didMove(toParent: self)
//        
//        NSLayoutConstraint.activate([
//            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            hostingController.view.widthAnchor.constraint(equalToConstant: 250),
//            hostingController.view.heightAnchor.constraint(equalToConstant: 250)
//        ])
//    }
//}
//
//
//@available(iOS 17.0, *)
//#Preview {
//    PieChartViewController()
//    
//}

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
