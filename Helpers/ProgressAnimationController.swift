//
//  ProgressAnimationController.swift
//  EarnLog
//
//  Created by M3 pro on 02/09/2025.
//


import UIKit

class ProgressAnimationController {
    var progressLayer: CAShapeLayer!
    
    // MARK: - Основные методы анимации
    
    // 1. Базовая анимация с контролем скорости
    func animateProgress(to newProgress: CGFloat, duration: TimeInterval = 3.0) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = newProgress
        animation.duration = duration
        
        // Различные типы timing функций
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        // Другие варианты:
        // .linear - равномерно
        // .easeIn - медленный старт
        // .easeOut - медленный финиш
        // .easeInEaseOut - медленный старт и финиш
        
        progressLayer.add(animation, forKey: "progressAnimation")
        progressLayer.strokeEnd = newProgress
    }
    
    // 2. Анимация с задержкой
    func animateProgressWithDelay(to newProgress: CGFloat, delay: TimeInterval = 1.0) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = newProgress
        animation.duration = 2.0
        animation.beginTime = CACurrentMediaTime() + delay // Задержка перед стартом
        animation.fillMode = .backwards // Сохранять состояние до начала
        
        progressLayer.add(animation, forKey: "progressAnimation")
        progressLayer.strokeEnd = newProgress
    }
    
    // 3. Анимация с повторением
    func animateProgressRepeating(to newProgress: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = newProgress
        animation.duration = 2.0
        animation.repeatCount = 3 // Повторить 3 раза
        // animation.repeatCount = .infinity // Бесконечно
        animation.autoreverses = true // Анимация в обратную сторону
        
        progressLayer.add(animation, forKey: "progressAnimation")
        progressLayer.strokeEnd = newProgress
    }
    
    // 4. Кастомная кривая Безье
    func animateProgressCustomTiming(to newProgress: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = newProgress
        animation.duration = 3.0
        
        // Кастомная кривая (очень медленный старт, быстрый финиш)
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.0, 0.0, 0.2, 1.0)
        
        progressLayer.add(animation, forKey: "progressAnimation")
        progressLayer.strokeEnd = newProgress
    }
    
    // 5. Группа анимаций (анимируем несколько свойств одновременно)
    func animateProgressWithColor(to newProgress: CGFloat) {
        let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressAnimation.fromValue = progressLayer.strokeEnd
        progressAnimation.toValue = newProgress
        
        let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
        colorAnimation.fromValue = UIColor.blue.cgColor
        colorAnimation.toValue = UIColor.green.cgColor
        
        let group = CAAnimationGroup()
        group.animations = [progressAnimation, colorAnimation]
        group.duration = 3.0
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        progressLayer.add(group, forKey: "progressGroup")
        progressLayer.strokeEnd = newProgress
        progressLayer.strokeColor = UIColor.green.cgColor
    }
    
    // 6. Keyframe анимация (несколько этапов)
    func animateProgressKeyframes(to newProgress: CGFloat) {
        let animation = CAKeyframeAnimation(keyPath: "strokeEnd")
        
        // Значения в разные моменты времени
        animation.values = [0.0, 0.3, 0.2, newProgress]
        
        // Время для каждого значения (опционально)
        animation.keyTimes = [0.0, 0.3, 0.6, 1.0]
        
        animation.duration = 4.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        progressLayer.add(animation, forKey: "progressKeyframes")
        progressLayer.strokeEnd = newProgress
    }
    
    // 7. Пружинная анимация (iOS 9+)
    func animateProgressSpring(to newProgress: CGFloat) {
        let animation = CASpringAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = newProgress
        
        animation.damping = 10.0          // Затухание (чем больше, тем меньше колебаний)
        animation.stiffness = 100.0       // Жесткость пружины
        animation.mass = 1.0              // Масса объекта
        animation.initialVelocity = 0.0   // Начальная скорость
        
        animation.duration = animation.settlingDuration // Автоматический расчет времени
        
        progressLayer.add(animation, forKey: "progressSpring")
        progressLayer.strokeEnd = newProgress
    }
    
    // MARK: - Контроль анимации
    
    // Пауза анимации
    func pauseAnimation() {
        let pausedTime = progressLayer.convertTime(CACurrentMediaTime(), from: nil)
        progressLayer.speed = 0.0
        progressLayer.timeOffset = pausedTime
    }
    
    // Возобновление анимации
    func resumeAnimation() {
        let pausedTime = progressLayer.timeOffset
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        let timeSincePause = progressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        progressLayer.beginTime = timeSincePause
    }
    
    // Остановка анимации
    func stopAnimation() {
        progressLayer.removeAnimation(forKey: "progressAnimation")
        // или удалить все анимации:
        // progressLayer.removeAllAnimations()
    }
    
    // Проверка состояния анимации
    func isAnimating() -> Bool {
        return progressLayer.animation(forKey: "progressAnimation") != nil
    }
    
    // MARK: - Делегат анимации
    
    func animateProgressWithDelegate(to newProgress: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = newProgress
        animation.duration = 3.0
//        animation.delegate = self // Не забудьте добавить CAAnimationDelegate
        
        progressLayer.add(animation, forKey: "progressAnimation")
        progressLayer.strokeEnd = newProgress
    }
}

//// MARK: - CAAnimationDelegate
//extension ProgressAnimationController: CAAnimationDelegate {
//    func animationDidStart(_ anim: CAAnimation) {
//        print("Анимация началась")
//    }
//    
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        if flag {
//            print("Анимация завершилась успешно")
//        } else {
//            print("Анимация была прервана")
//        }
//    }
//}

// MARK: - Дополнительные эффекты

extension ProgressAnimationController {
    
    // Анимация с изменением толщины линии
    func animateProgressWithLineWidth(to newProgress: CGFloat) {
        let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressAnimation.fromValue = progressLayer.strokeEnd
        progressAnimation.toValue = newProgress
        
        let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineWidthAnimation.fromValue = progressLayer.lineWidth
        lineWidthAnimation.toValue = progressLayer.lineWidth * 1.5
        
        let group = CAAnimationGroup()
        group.animations = [progressAnimation, lineWidthAnimation]
        group.duration = 2.0
        group.autoreverses = true
        
        progressLayer.add(group, forKey: "progressWithLineWidth")
        progressLayer.strokeEnd = newProgress
    }
    
    // Пульсирующий эффект
    func addPulseEffect() {
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 0.3
        pulseAnimation.toValue = 1.0
        pulseAnimation.duration = 1.0
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.autoreverses = true
        
        progressLayer.add(pulseAnimation, forKey: "pulse")
    }
    
    // Анимация появления с масштабированием
    func animateProgressWithScale(to newProgress: CGFloat) {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = 0.5
        
        let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressAnimation.fromValue = 0.0
        progressAnimation.toValue = newProgress
        progressAnimation.duration = 2.0
        progressAnimation.beginTime = 0.5 // Начать после масштабирования
        
        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, progressAnimation]
        group.duration = 2.5
        
        progressLayer.add(group, forKey: "scaleAndProgress")
        progressLayer.strokeEnd = newProgress
    }
}


import UIKit

class AnimatedLabel {
    
    // MARK: - Метод 1: Только CADisplayLink (рекомендуемый)
    
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    private var animationDuration: TimeInterval = 0
    private var startValue: Int = 0
    private var endValue: Int = 0
    private weak var valueLabel: UILabel?
    
    func animateValue(in label: UILabel, from start: Int, to end: Int, duration: TimeInterval) {
        print("Called: AnimatedLabel.animateValue")
        // Останавливаем предыдущую анимацию если есть
        stopAnimation()
        
        self.valueLabel = label
        self.startValue = start
        self.endValue = end
        self.animationDuration = duration
        self.animationStartTime = CACurrentMediaTime()
        
        // Создаем и настраиваем DisplayLink
        displayLink = CADisplayLink(target: self, selector: #selector(updateValue))
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .current, forMode: .default)
        
    }
    
    @objc private func updateValue() {
        let elapsed = CACurrentMediaTime() - animationStartTime
        let progress = min(elapsed / animationDuration, 1.0)
        
        // Применяем easing функцию
        let easedProgress = easeOutCubic(progress)
        
        let currentValue = startValue + Int(Double(endValue - startValue) * easedProgress)
        valueLabel?.text = "$\(currentValue)"
        
        if progress >= 1.0 {
            stopAnimation()
            valueLabel?.text = "$\(endValue)" // Финальное значение
        }
    }
    
    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func easeOutCubic(_ t: Double) -> Double {
        return 1 - pow(1 - t, 3)
    }
    
    deinit {
        stopAnimation()
    }
    
    // MARK: - Метод 2: UIView.animate с промежуточными значениями
    
    func animateValueWithUIView(in label: UILabel, from start: Int, to end: Int, duration: TimeInterval) {
        let steps = Int(duration * 60) // 60 FPS
        let stepDuration = duration / Double(steps)
        _ = Double(end - start) / Double(steps)
        
        for i in 0...steps {
            let delay = Double(i) * stepDuration
            let progress = Double(i) / Double(steps)
            let easedProgress = easeOutCubic(progress)
            let currentValue = start + Int(Double(end - start) * easedProgress)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                label.text = "$\(currentValue)"
            }
        }
    }
    
    // MARK: - Метод 3: Использование CABasicAnimation с KVO
    
    @objc dynamic var animatedValue: CGFloat = 0 {
        didSet {
            valueLabel?.text = "$\(Int(animatedValue))"
        }
    }
    
    func animateValueWithCoreAnimation(in label: UILabel, from start: Int, to end: Int, duration: TimeInterval) {
        self.valueLabel = label
        
        // Создаем анимацию для нашего свойства
        let animation = CABasicAnimation(keyPath: "animatedValue")
        animation.fromValue = start
        animation.toValue = end
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0) // easeOut
        
        // Устанавливаем финальное значение
        animatedValue = CGFloat(end)
        
        // Добавляем анимацию
//        layer.add(animation, forKey: "valueAnimation")
    }
    
    // MARK: - Метод 4: Closure-based анимация
    
    private var animationWorkItem: DispatchWorkItem?
    
    func animateValueWithClosure(in label: UILabel, from start: Int, to end: Int, duration: TimeInterval) {
        // Отменяем предыдущую анимацию
        animationWorkItem?.cancel()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let valueDiff = end - start
        
        func updateValue() {
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            let progress = min(elapsed / duration, 1.0)
            let easedProgress = easeOutCubic(progress)
            
            let currentValue = start + Int(Double(valueDiff) * easedProgress)
            label.text = "$\(currentValue)"
            
            if progress < 1.0 {
                let workItem = DispatchWorkItem { updateValue() }
                animationWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0/60.0, execute: workItem)
            } else {
                label.text = "$\(end)"
                animationWorkItem = nil
            }
        }
        
        updateValue()
    }
    
    // MARK: - Метод 5: Используя UIViewPropertyAnimator
    
    private var animator: UIViewPropertyAnimator?
    
    func animateValueWithPropertyAnimator(in label: UILabel, from start: Int, to end: Int, duration: TimeInterval) {
        animator?.stopAnimation(true)
        
        _ = CACurrentMediaTime()
        let valueDiff = end - start
        
        animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            // Пустой блок анимации, мы будем использовать addAnimations
        }
        
        animator?.addAnimations {
            // Здесь мы не анимируем реальные свойства, а используем прогресс
        }
        
        // Отслеживаем прогресс
        let displayLink = CADisplayLink { [weak self] in
            guard let animator = self?.animator else { return }
            
            let progress = animator.fractionComplete
            let easedProgress = self?.easeOutCubic(Double(progress)) ?? Double(progress)
            let currentValue = start + Int(Double(valueDiff) * easedProgress)
            
            DispatchQueue.main.async {
                label.text = "$\(currentValue)"
            }
            
//            if progress >= 1.0 {
//                displayLink.invalidate()
//            }
        }
        displayLink.add(to: .current, forMode: .default)
        
        animator?.startAnimation()
    }
    
    // MARK: - Вспомогательные функции easing
    
    private func easeInOut(_ t: Double) -> Double {
        return t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }
    
    private func easeIn(_ t: Double) -> Double {
        return t * t
    }
    
    private func easeOut(_ t: Double) -> Double {
        return 1 - pow(1 - t, 2)
    }
    
    private func elasticOut(_ t: Double) -> Double {
        let c4 = (2 * Double.pi) / 3
        return t == 0 ? 0 : t == 1 ? 1 : pow(2, -10 * t) * sin((t * 10 - 0.75) * c4) + 1
    }
    
    private func bounceOut(_ t: Double) -> Double {
        let n1 = 7.5625
        let d1 = 2.75
        
        if t < 1 / d1 {
            return n1 * t * t
        } else if t < 2 / d1 {
            let t2 = t - 1.5 / d1
            return n1 * t2 * t2 + 0.75
        } else if t < 2.5 / d1 {
            let t2 = t - 2.25 / d1
            return n1 * t2 * t2 + 0.9375
        } else {
            let t2 = t - 2.625 / d1
            return n1 * t2 * t2 + 0.984375
        }
    }
}

// MARK: - Расширение для CADisplayLink с замыканием
extension CADisplayLink {
    convenience init(closure: @escaping () -> Void) {
        self.init(target: CADisplayLinkTarget(closure: closure), selector: #selector(CADisplayLinkTarget.execute))
    }
}

private class CADisplayLinkTarget {
    let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    @objc func execute() {
        closure()
    }
}

// MARK: - Пример использования
/*
class ViewController: UIViewController {
    @IBOutlet weak var valueLabel: UILabel!
    private let animatedLabel = AnimatedLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Используем любой из методов:
        animatedLabel.animateValue(in: valueLabel, from: 0, to: 1000, duration: 2.0)
        
        // Или другой метод:
        // animatedLabel.animateValueWithUIView(in: valueLabel, from: 0, to: 1000, duration: 2.0)
    }
}
*/
