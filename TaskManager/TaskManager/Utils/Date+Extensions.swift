//
//  Date+Extensions.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 23/09/25.
//

import SwiftUI

// MARK: - Extensões de data necessárias para a construção da interface do usuário
extension Date {
    // Formato de data personalizado
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    // Verificando se a data é hoje
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    // Buscando Semana com Base na Data Fornecida
    func fetchWeek(_ date: Date = .init()) -> [WeekDay] {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        
        var week: [WeekDay] = []
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let startOfWeek = weekForDate?.start else {
            return []
        }
        
        for i in 0 ..< 7 {
            if let weekDay = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                week.append(.init(date: weekDay))
            }
        }
    
        return week
    }
    
    struct WeekDay: Identifiable {
        let id: UUID = .init()
        let date: Date
    }
}
