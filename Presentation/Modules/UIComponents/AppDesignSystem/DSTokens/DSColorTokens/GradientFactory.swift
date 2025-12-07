//
//  GradientFactory.swift
//  EarnLog
//
//  Created by M3 pro on 31/08/2025.
//
import UIKit

enum GradientFactory {
    static func makeLayer(colors: [CGColor],
                          start: CGPoint = CGPoint(x: 0, y: 0),
                          end: CGPoint = CGPoint(x: 1, y: 1),
                          frame: CGRect) -> CAGradientLayer {

        let g = CAGradientLayer()
        g.colors = colors
        g.startPoint = start
        g.endPoint = end
        g.frame = frame
        g.type = .axial
        g.locations = [0, 1]
        return g
    }
}
