//
//  File.swift
//  JobData
//
//  Created by M3 pro on 25/07/2025.
//
import SwiftUI
import Charts

struct BarChart: View {
    var groupedItems: [DailyTotal]
    var targetValue: Double? // ← Целевое значение
    
    // Текущая выбранная дата в графике
    @State private var selectedDate: String?
    
    // Выбранная подсказка легенды (например, "Good" -> "Это хорошая сумма")
    @State private var selectedLegendHint: String?

    var body: some View {
        ZStack {
            // Основной контент
            VStack {
                ScrollView(.horizontal) {
                    if #available(iOS 17.0, *) {
                        Chart {
                            ForEach(groupedItems) { item in
                                BarMark(
                                    x: .value("Дата", item.formattedDate),
                                    y: .value("Сумма", item.totalPrice)
                                )
                                .foregroundStyle(color(for: item.totalPrice)) // цвет зависит от суммы
                                .cornerRadius(5)
                                .annotation(position: .top) {
                                    // Если выбрана именно эта дата — показываем аннотацию
                                    if selectedDate == item.formattedDate {
                                        Text("\(Int(item.totalPrice)) zł\n\(item.formattedDate)")
                                            .font(.caption)
                                            .padding(4)
                                            .background(.gray.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                }
                            }
                            // Горизонтальная линия целевого значения
                            if let target = targetValue {
                                RuleMark(y: .value("Цель", target))
                                    .foregroundStyle(.blue)
                                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                                    .annotation(position: .top, alignment: .leading) {
                                        Text("Target: \(Int(target)) zł")
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                            }
                            
                            // Вертикальная линия при выборе даты
                            if let selected = selectedDate {
                                RuleMark(x: .value("Выбрано", selected))
                                    .foregroundStyle(.black)
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                            }
                        }
                        .chartXSelection(value: $selectedDate) // привязка выбора по оси X
                        .frame(width: CGFloat(max(400, groupedItems.count * 50)), height: 300)
                        .padding()
                    } else {
                        // Fallback on earlier versions
                    }
                }

                legendView // легенда под графиком
            }

            // Всплывающее окно подсказки, если нажал на элемент легенды
            if let hint = selectedLegendHint {
                VStack {
                    Text(hint)
                        .font(.caption)
                        .padding()
                        .background(.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top, 250)
                    Spacer()
                }
                .transition(.opacity)
                .onTapGesture {
                    selectedLegendHint = nil // если нажал на подсказку — скрыть
                }
            }
        }
        // Если нажал в любое другое место — сбросить подсказку
        .contentShape(Rectangle())
        .onTapGesture {
            selectedLegendHint = nil
        }
    }

    /// Цвет столбика по сумме
    private func color(for total: Double) -> Color {
        switch total {
        case ..<500: return .red
        case 500..<800: return .orange
        case 800..<1200: return .blue
        default: return .green
        }
    }

    /// Легенда под графиком с возможностью показать пояснение
    private var legendView: some View {
        HStack(spacing: 15) {
            legendItem(text: "Poor", color: .red, hint: "Less than 500 zł — Low")
            legendItem(text: "Fair", color: .orange, hint: "500–800 zł — Moderate")
            legendItem(text: "Good", color: .blue, hint: "800–1200 zł — Good")
            legendItem(text: "Excellent", color: .green, hint: "Over 1200 zł — Excellent")
        }
        .font(.caption2)
        .bold()
        .padding(.horizontal)
    }

    /// Один элемент легенды (цвет + текст)
    private func legendItem(text: String, color: Color, hint: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "square.fill")
                .foregroundColor(color)
            Text(text)
                .foregroundColor(.black)
        }
        .onTapGesture {
            // при нажатии показываем подсказку
            selectedLegendHint = hint
        }
    }
}
