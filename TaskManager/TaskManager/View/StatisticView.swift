//
//  StatisticView.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 29/09/25.
//

import SwiftUI

struct StatisticView: View {
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                StatisticItem(title: "Total Concluídas", image: "checkmark.circle", value: "2", color: .colorGreen)
                StatisticItem(title: "Taxa de Conclusão", image: "chart.pie", value: "13%", color: .colorBlue)
                StatisticItem(title: "Concluídas (Semana)", image: "calendar", value: "2", color: .colorPurple)
                StatisticItem(title: "Concluídas (Mês)", image: "chart.line.uptrend.xyaxis", value: "2", color: .colorOrange)
            }
            .padding()
        }
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
