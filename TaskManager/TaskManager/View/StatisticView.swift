//
//  StatisticView.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 29/09/25.
//

import SwiftUI
import Charts
import SwiftData

enum TypeChart: String, CaseIterable {
    case semanal
    case mensal
}

struct StatisticView: View {
    @Query var tasks: [Task]
    
    @State private var selectedPeriod: TypeChart = .semanal
    
    var body: some View {
        let totalCompleted = tasks.completedTasks.count
        let weeklyCompleted = tasks.completedThisWeek().count
        let monthlyCompleted = tasks.completedThisMonth().count
        let completionRate = tasks.completionRate
        
        VStack(spacing: 20) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                StatisticItem(
                    title: "Total Concluídas",
                    image: "checkmark.circle",
                    value: "\(totalCompleted)",
                    color: .colorGreen)
                
                StatisticItem(
                    title: "Taxa de Conclusão",
                    image: "chart.pie",
                    value: "\(completionRate)",
                    color: .colorBlue)
                
                StatisticItem(
                    title: "Concluídas (Semana)",
                              image: "calendar",
                    value: "\(weeklyCompleted)",
                    color: .colorPurple)
                
                StatisticItem(
                    title: "Concluídas (Mês)",
                    image: "chart.line.uptrend.xyaxis",
                    value: "\(monthlyCompleted)",
                    color: .colorOrange)
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Text("Progresso de Tarefas")
                        .font(.headline)
                    Picker("gege", selection: $selectedPeriod) {
                        ForEach(TypeChart.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }
                
                
                Chart {
                    ForEach(selectedPeriod == .semanal ? Array(tasks.completedGroupedByWeekday().keys) : Array(tasks.completeGroupedByMonth().keys) , id: \.self) { key in
                        if let count = selectedPeriod == .semanal ? tasks.completedGroupedByWeekday()[key] : tasks.completeGroupedByMonth()[key] {
                            BarMark(
                                x: .value(selectedPeriod == .semanal ? "Dia" : "Mês", key),
                                y: .value("Concluídas", count))
                        }
                    }
                }
            }
            .padding()
            .background(.colorGrid, in: .rect(cornerRadius: 16))
        }
        .padding()
    }
}

// MARK: - StatisticItem
extension StatisticView {
    @ViewBuilder
    func StatisticItem(title: String, image: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.colorTextForm)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                Spacer()
                Image(systemName: image)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .padding()
        .background(.colorGrid, in: .rect(cornerRadius: 16))
    }
}

#Preview {
    StatisticView()
}
