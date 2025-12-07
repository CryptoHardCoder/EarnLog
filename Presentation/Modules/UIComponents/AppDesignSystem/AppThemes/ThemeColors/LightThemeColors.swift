//
//  LightThemeColors.swift
//  EarnLog
//
//  Created by M3 pro on 30/11/2025.
//

import UIKit


struct LightThemeColors: ThemeColorsProtocol {

    let primary: UIColor = BaseColors.green500

    let primaryVariant: UIColor = BaseColors.green400

    let background: UIColor = BaseColors.white50

    let backgroundSecondary: UIColor = BaseColors.white200

    let textPrimary: UIColor = BaseColors.black900

    let textSecondary: UIColor = BaseColors.black400

    let textTertiary: UIColor = BaseColors.black300

    let textQuaternary: UIColor = BaseColors.black200

    let success: UIColor = BaseColors.green400

    let warning: UIColor = BaseColors.orange

    let error: UIColor = BaseColors.red

    let info: UIColor = BaseColors.blue

    let price: UIColor = BaseColors.green400

    let white: UIColor = BaseColors.white50

    let black: UIColor = BaseColors.black900

    let gray: UIColor = BaseColors.black300

    let itemCellsBackground: UIColor = BaseColors.white500

    let shadowColor: UIColor = BaseColors.black900

    let card: CardColors = CardColors(
        backgroundGradient: [
            UIColor(hex: "#0F8046").cgColor,
            UIColor(hex: "#92F8CA").cgColor,
        ],
        text: BaseColors.white700,
        gradientPoints: (
            start: CGPoint(x: 0.0, y: 1.0),
            end: CGPoint(x: 1.0, y: -0.5)
        )
    )

    let monthlyGoal: MonthlyGoalColors = MonthlyGoalColors(
        background: BaseColors.white50,
        levelBackground: BaseColors.green300,
        levelTitle: BaseColors.white50,
        chartBackground: BaseColors.white50,
        chartLineGradient: [
            UIColor(hex: "#92F8CA").cgColor,
            UIColor(hex: "#0F8046").cgColor,
        ],
        gradientPoints: (
            start: CGPoint(x: 0.9, y: 0.0),
            end: CGPoint(x: 0.1, y: 1.0)
        )
    )

    let stats: StatsColors = StatsColors(
        primary: BaseColors.green500,
        secondary: BaseColors.blue,
        tertiary: BaseColors.orange,
        quaternary: BaseColors.purple,
        viewButtonColor: BaseColors.red
    )

    let button: ButtonColors = ButtonColors(
        primary: BaseColors.green500,
        secondary: BaseColors.green700,
        disabled: BaseColors.white400,
        destructive: BaseColors.white200
    )

    let alert: AlertColors = AlertColors(
        background: BaseColors.white50,
        border: AlertColors.ButtonBorder.init(
            destructive: BaseColors.red,
            default: BaseColors.black300
        ),
        text: AlertColors.ButtonText.init(
            destructive: BaseColors.red,
            cancel: BaseColors.red.withAlphaComponent(0.8),
            default: BaseColors.white50
        ),
        button: AlertColors.ButtonBackground.init(
            primary: BaseColors.green500,
            default: BaseColors.white50
        )
    )
}
