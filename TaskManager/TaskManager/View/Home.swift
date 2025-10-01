//
//  Home.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 23/09/25.
//

import SwiftUI

struct Home: View {
    // Task Manager Properties
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    @State private var createWeek: Bool = false
    @State private var createNewTask: Bool = false
    @State private var searchTask: String = ""
    @State private var categoryFilter: String = ""
    @State private var showTaskFilter: Bool = false
    @State private var showStatisticView: Bool = false
    
    // Animation namespace
    @Namespace private var animation
    
    let categories: [Category] = [
        .trabalho, .estudo, .pessoal, .saude, .compras, .lazer
    ]
    let colors: [String] = ["colorBlue", "colorGreen", "colorRed", "colorYellow", "colorPurple", "colorOrange"]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HeaderView()
                
                SerchTextView()
                CategoryFilterView()
                
                ScrollView(.vertical) {
                    // Tasks View
                    TasksView(currentDate: $currentDate, searchTask: $searchTask, categoryFilter: $categoryFilter)
                    
                }
                .hSpacing(.center)
            }
            .vSpacing(.top)
            .overlay(alignment: .bottomTrailing, content: {
                Button {
                    createNewTask.toggle()
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 55, height: 55)
                        .background(.colorGridCategory.shadow(.drop(color: .black.opacity(0.25), radius: 16)), in: .circle)
                }
                .padding(15)
            })
            .overlay(alignment: .topTrailing, content: {
                Button(action: {
                    showStatisticView.toggle()
                }) {
                    Image(systemName: "chart.bar.yaxis")
                        .padding()
                        .foregroundStyle(.colorTextForm)
                        .font(.title3)
                }
            })
            .onAppear {
                if weekSlider.isEmpty {
                    let currentWeek = Date().fetchWeek()
                    
                    if let firstDate = currentWeek.first?.date {
                        weekSlider.append(firstDate.createPreviousWeek())
                    }
                    
                    weekSlider.append(currentWeek)
                    
                    if let lastDate = currentWeek.last?.date {
                        weekSlider.append(lastDate.createNextWeek())
                    }
                }
            }
            .sheet(isPresented: $createNewTask) {
                TaskFormView()
                    .presentationDetents([.fraction(0.9)])
                    .interactiveDismissDisabled()
            }
            .navigationDestination(isPresented: $showStatisticView) {
                StatisticView()
            }
        }
    }
}

// MARK: - HeaderView
extension Home {
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Text(currentDate.format("MMM"))
                    .foregroundStyle(.blue)
                
                Text(currentDate.format("YYYY"))
                    .foregroundStyle(.gray)
            }
            .font(.title.bold())
            
            Text(currentDate.formatted(date: .complete, time: .omitted))
                .font(.caption)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .foregroundStyle(.gray)
            
            // WeekSlider
            TabView(selection: $currentWeekIndex) {
                ForEach(weekSlider.indices, id: \.self) { index in
                    let week = weekSlider[index]
                    WeekView(week)
                        .padding(.horizontal, 15)
                        .tag(index)
                }
            }
            .padding(.horizontal, -15)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 90)
        }
        .hSpacing(.leading)
        .padding(15)
        .background(.background)
        .onChange(of: currentWeekIndex, initial: false) { oldValue, newValue in
            // Criando quando chega na primeira/última página
            if newValue == 0 || newValue == (weekSlider.count - 1) {
                createWeek = true
            }
        }
    }
}

// MARK: - SearchTextView
extension Home {
    @ViewBuilder
    func SerchTextView() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Buscar tarefas...", text: $searchTask)
            Button(action: {
                withAnimation {
                    showTaskFilter.toggle()
                }
            }) {
                Image(systemName: "line.3.horizontal.decrease")
                    .padding(6)
                    .foregroundStyle(showTaskFilter ? .white : .secondary)
                    .background(showTaskFilter ? .colorBlue : .clear, in: .rect(cornerRadius: 8))
            }
        }
        .padding()
        .foregroundStyle(.secondary)
        .background(.colorGrid, in: .rect(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - CategoryFilterView
extension Home {
    @ViewBuilder
    func CategoryFilterView() -> some View {
        if showTaskFilter {
            VStack(alignment: .leading, spacing: 10) {
                Text("Categorias")
                    .font(.footnote)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))]) {
                    ForEach(categories.enumerated(), id: \.1) { index, category in
                        Button(action: {
                            withAnimation {
                                categoryFilter = category.rawValue
                            }
                        }) {
                            Text(category.rawValue)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                                .foregroundStyle(categoryFilter == category.rawValue ? .white : .colorTextForm)
                                .background(categoryFilter == category.rawValue ? Color(colors[index])  : .colorGridPriority.opacity(0.3), in: .rect(cornerRadius: 16))
                        }
                    }
                }
                
                Button(action: {
                    categoryFilter = ""
                }) {
                    Label("Limpar filtros", systemImage: "xmark")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .background(.colorGrid, in: .rect(cornerRadius: 16))
            .padding()
            .animation(.linear, value: showTaskFilter)
        }
    }
}

// MARK: - WeekView
extension Home {
    @ViewBuilder
    func WeekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 0) {
            ForEach(week) { day in
                VStack(spacing: 5) {
                    Text(day.date.format("E"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)
                    
                    Text(day.date.format("dd"))
                        .font(.headline)
                        .fontWeight(.bold)
                        .textScale(.secondary)
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white : .secondary)
                        .frame(width: 45, height: 45)
                        .background {
                            if isSameDate(day.date, currentDate) {
                                Circle()
                                    .fill(.colorGridCategory)
                                    .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
                            }
                        }
                }
                .hSpacing(.center)
                .contentShape(.rect)
                .onTapGesture {
                    // Atualizando a data atual
                    withAnimation(.snappy) {
                        currentDate = day.date
                    }
                }
            }
        }
        .background {
            GeometryReader {
                let minX = $0.frame(in: .global).minX
                
                Color.clear
                    .preference(key: OffsetKey.self, value: minX)
                    .onPreferenceChange(OffsetKey.self) { value in
                        // Quando o deslocamento atinge 15 e se o createWeek for alternado, então simplesmente gera o próximo conjunto de semanas
                        if value.rounded() == 15 && createWeek {
                            paginateWeek()
                            createWeek = false
                        }
                    }
            }
        }
    }
}

// MARK: - Paginate Week
extension Home {
    func paginateWeek() {
        // Verificação Segura
        if weekSlider.indices.contains(currentWeekIndex) {
            if let firstDate = weekSlider[currentWeekIndex].first?.date, currentWeekIndex == 0 {
                // Inserindo uma nova semana no índice 0 e removendo o último item da matriz
                weekSlider.insert(firstDate.createPreviousWeek(), at: 0)
                weekSlider.removeLast()
                currentWeekIndex = 1
            }
            
            if let lastDate = weekSlider[currentWeekIndex].last?.date, currentWeekIndex == (weekSlider.count - 1) {
                // Acrescentando uma nova semana no último índice e removendo o primeiro item da matriz
                weekSlider.append(lastDate.createNextWeek())
                weekSlider.removeFirst()
                currentWeekIndex = weekSlider.count - 2
            }
        }
    }
}

#Preview {
    ContentView()
}
