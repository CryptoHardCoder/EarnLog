//
//  SubViewColors.swift
//  EarnLog
//
//  Created by M3 pro on 30/11/2025.
//
import UIKit

struct CardColors {
    let backgroundGradient: [CGColor]
    let text: UIColor
    let gradientPoints: (start: CGPoint, end: CGPoint)
}

struct MonthlyGoalColors {
    let background: UIColor
    let levelBackground: UIColor
    let levelTitle: UIColor
    let chartBackground: UIColor
    let chartLineGradient: [CGColor]
    let gradientPoints: (start: CGPoint, end: CGPoint)
}

struct StatsColors {
    let primary: UIColor
    let secondary: UIColor
    let tertiary: UIColor
    let quaternary: UIColor
    let viewButtonColor: UIColor
}

struct ButtonColors {
    let primary: UIColor
    let secondary: UIColor
    let disabled: UIColor
    let destructive: UIColor
}

struct AlertColors {

    struct ButtonBorder {
        let destructive: UIColor
        let `default`: UIColor
    }

    struct ButtonText {
        let destructive: UIColor
        let cancel: UIColor
        let `default`: UIColor
    }

    struct ButtonBackground {
        let primary: UIColor
        let `default`: UIColor
    }

    let background: UIColor
    let border: ButtonBorder
    let text: ButtonText
    let button: ButtonBackground
}
