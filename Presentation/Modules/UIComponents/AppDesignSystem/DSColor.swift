//
//  DSColors.swift
//  EarnLog
//
//  Created by M3 pro on 17/11/2025.
//
import UIKit


enum DSColors {
    private static var themeColors: ThemeColorsProtocol {
        return ThemeProvider.colors(for: UITraitCollection.current.appTheme)
    }

    static var appPrimary: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).primary
        }
    }
    static var appBackground: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).background
        }
    }
    static var appTextPrimary: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).textPrimary
        }
    }
    static var appTextSecondary: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).textSecondary
        }
    }
    static var appTextTertiary: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).textTertiary
        }
    }
    static var appTextQuaternary: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).textQuaternary
        }
    }

    static var success: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).success
        }
    }
    static var warning: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).warning
        }
    }
    static var error: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).error
        }
    }
    static var info: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).info
        }
    }

    static var black: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).black
        }
    }
    static var white: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).white
        }
    }
    static var gray: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).gray
        }
    }

    static var cellsBackground: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme)
                .itemCellsBackground
        }
    }
    static var priceColor: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).price
        }
    }
    static var shadowColor: UIColor {
        UIColor { traitCollection in
            ThemeProvider.colors(for: traitCollection.appTheme).shadowColor
        }
    }

    enum CardViewColors {
        static var textColor: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).card.text
            }
        }
        static var cardGradientColors: [CGColor] {
            themeColors.card.backgroundGradient
        }
        static var gradientPoints: (start: CGPoint, end: CGPoint) {
            themeColors.card.gradientPoints
        }
    }

    enum MonthlyGoalCardColors {
        static var background: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).monthlyGoal
                    .background
            }
        }
        static var levelBackgroundColor: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).monthlyGoal
                    .levelBackground
            }
        }
        static var levelTitleColor: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).monthlyGoal
                    .levelTitle
            }
        }

        static var semiChartBackground: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).monthlyGoal
                    .chartBackground
            }
        }
        static var semiChartLineGradientColors: [CGColor] {
            themeColors.monthlyGoal.chartLineGradient
        }
        static var gradientPoints: (start: CGPoint, end: CGPoint) {
            themeColors.card.gradientPoints
        }
    }

    enum StatsCardColors {
        static var mainJobStatsColor: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).stats
                    .primary
            }
        }
        static var secondarySideJobColor: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).stats
                    .secondary
            }
        }
        static var tertiarySideJobColor: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).stats
                    .tertiary
            }
        }
        static var smallestSideJobColor: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).stats
                    .quaternary
            }
        }
        static var viewButtonColor: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).stats
                    .viewButtonColor
            }
        }
    }

    enum ButtonColors {
        static var primaryButtonColor: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).button
                    .primary
            }
        }
        static var buttonDisabledColor: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).button
                    .disabled
            }
        }
        static var buttonTappedColor: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).button
                    .secondary
            }
        }
        static var destructiveButtonColor: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).button
                    .destructive
            }
        }
    }

    enum AlertColors {
        static var background: UIColor {
            UIColor { traitCollection in
                ThemeProvider.colors(for: traitCollection.appTheme).alert
                    .background
            }
        }
        enum ButtonBorder {
            static var destructive: UIColor {
                UIColor { traitCollection in
                    ThemeProvider.colors(for: traitCollection.appTheme).alert
                        .border.destructive
                }
            }
            static var `default`: UIColor {
                UIColor { traitCollection in
                    ThemeProvider.colors(for: traitCollection.appTheme).alert
                        .border.default
                }
            }
        }

        enum Text {
            static var destructive: UIColor {
                UIColor { traitCollection in
                    ThemeProvider.colors(for: traitCollection.appTheme).alert
                        .text.destructive
                }
            }
            static var `default`: UIColor {
                UIColor { traitCollection in
                    ThemeProvider.colors(for: traitCollection.appTheme).alert
                        .text.default
                }
            }
            static var cancel: UIColor {
                UIColor { traitCollection in
                    ThemeProvider.colors(for: traitCollection.appTheme).alert
                        .text.cancel
                }
            }
        }

        enum ButtonBackground {
            static var primary: UIColor {
                UIColor { traitCollection in
                    ThemeProvider.colors(for: traitCollection.appTheme).alert
                        .button.primary
                }
            }
            static var `default`: UIColor {
                UIColor { traitCollection in
                    ThemeProvider.colors(for: traitCollection.appTheme).alert
                        .button.default
                }
            }
        }

    }

}


// MARK: - Base Colors (Private)
/// Базовая палитра цветов - не используется напрямую в коде приложения


//private enum BaseGradients {
//    var greenForCard: [CGColor] {
//        [
//            UIColor(hex: "#0F8046").cgColor,
//            UIColor(hex: "#92F8CA").cgColor,
//        ]
//    }
//
//    var greenForChart: [CGColor] {
//        [
//            UIColor(hex: "#92F8CA").cgColor,
//            UIColor(hex: "#0F8046").cgColor,
//        ]
//    }
//}

