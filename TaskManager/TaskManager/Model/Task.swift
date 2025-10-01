//
//  Task.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 23/09/25.
//

import SwiftUI
import SwiftData

// MARK: - Task Model
@Model
class Task: Identifiable {
    var id: UUID
    var taskTitle: String
    var taskDescription: String?
    var creationDate: Date
    var isComplete: Bool = false
    var completeDate: Date? = nil
    var tint: String
    var category: Category
    
    var repeatOptionRawValue: String
    var repeatOptions: Repeat {
        get { return Repeat(rawValue: repeatOptionRawValue) ?? .nunca }
        set { repeatOptionRawValue = newValue.rawValue }
    }
    
    var priority: Priority
    var nextOccurrenceDate: Date // Adicionado para a próxima ocorrência
    var parentTaskID: UUID?
    var isRecurringInstance: Bool
    
    init(id: UUID = .init(), taskTitle: String, taskDescription: String?, creationDate: Date = .init(), isComplete: Bool = false, completeDate: Date? = nil, tint: String, category: Category, repeatOptions: Repeat, priority: Priority, parentTaskID: UUID? = nil, isRecurringInstance: Bool = false) {
        self.id = id
        self.taskTitle = taskTitle
        self.taskDescription = taskDescription
        self.creationDate = creationDate
        self.isComplete = isComplete
        self.completeDate = completeDate
        self.tint = tint
        self.category = category
        self.repeatOptionRawValue = repeatOptions.rawValue
        self.priority = priority
        self.parentTaskID = parentTaskID
        self.isRecurringInstance = isRecurringInstance
        
        self.nextOccurrenceDate = Self.calculateNextOccurrence(for: creationDate, repeatOption: repeatOptions)
        
        NotificationManger.shared.scheduleNotification(for: self)
    }
    
    var tintColor: Color {
        switch tint {
        case "colorBlue": return .colorBlue
        case "colorYellow": return .colorYellow
        case "colorGreen": return .colorGreen
        case "colorPurple": return .colorPurple
        case "colorRed": return .colorRed
        case "colorOrange": return .colorOrange
        default: return .black
        }
    }
    
    // MARK: - Lógica de Recorrência
    static func calculateNextOccurrence(for date: Date, repeatOption: Repeat) -> Date {
        let calendar = Calendar.current
        switch repeatOption {
        case .nunca:
            return date // Tarefas que não se repetem têm a própria data de criação como próxima ocorrência
        case .diaria:
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        case .semanal:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .mensal:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        }
    }
    
    // Função para gerar a próxima instância de uma tarefa recorrente
    func generateNextOccurrence() -> Task? {
        guard repeatOptions != .nunca else { return nil }
        
        let calendar = Calendar.current
        var newCreationDate: Date
        
        switch repeatOptions {
        case .diaria:
            newCreationDate = calendar.date(byAdding: .day, value: 1, to: creationDate) ?? creationDate
        case .semanal:
            newCreationDate = calendar.date(byAdding: .weekOfYear, value: 1, to: creationDate) ?? creationDate
        case .mensal:
            newCreationDate = calendar.date(byAdding: .month, value: 1, to: creationDate) ?? creationDate
        case .nunca:
            return nil // Não deve acontecer devido ao guard
        }
        
        // Garante que a nova tarefa seja criada para o futuro, se a data de criação original já passou
        if newCreationDate < Date() && repeatOptions != .nunca {
            // Se a próxima ocorrência calculada for no passado, avançamos até o futuro
            var tempDate = newCreationDate
            while tempDate < Date() {
                switch repeatOptions {
                case .diaria:
                    tempDate = calendar.date(byAdding: .day, value: 1, to: tempDate) ?? tempDate
                case .semanal:
                    tempDate = calendar.date(byAdding: .weekOfYear, value: 1, to: tempDate) ?? tempDate
                case .mensal:
                    tempDate = calendar.date(byAdding: .month, value: 1, to: tempDate) ?? tempDate
                case .nunca:
                    break
                }
            }
            newCreationDate = tempDate
        }
        
        let nextTask = Task(
            taskTitle: self.taskTitle,
            taskDescription: self.taskDescription,
            creationDate: newCreationDate,
            isComplete: false,
            completeDate: completeDate,// Nova instância não está completa
            tint: self.tint,
            category: self.category,
            repeatOptions: self.repeatOptions,
            priority: self.priority,
            parentTaskID: self.parentTaskID ?? self.id, // A tarefa original é o pai, ou ela mesma se for a primeira
            isRecurringInstance: true // Marca como instância recorrente
        )
        return nextTask
    }
    
    // MARK: - Gerenciamento de Notificações para a Tarefa
    func updateNotication() {
        NotificationManger.shared.cancelNotification(for: self.id)
        
        if !self.isComplete {
            NotificationManger.shared.scheduleNotification(for: self)
        }
    }
    
    func cancelTaskNotification() {
        NotificationManger.shared.cancelNotification(for: self.id)
    }
}

// MARK: - Extension Date
extension Date {
    static func updateHour(_ value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: value, to: .init()) ?? .init()
    }
    
    static func startOfWeek(date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? .init()
    }
    
    static func endOfWeek(date: Date) -> Date {
        let calendar = Calendar.current
        let start = startOfWeek(date: date)
        let end = calendar.date(byAdding: .day, value: 6, to: start) ?? start
        return end
    }
}

// MARK: - Estatísticas de Tarefas
extension Array where Element == Task {
    
    // Retornar todas as tarefas concluídas.
    var completedTasks: [Task] {
        filter { $0.isComplete && $0.completeDate != nil }
    }
    
    // Retornar a porcentagem de tarefas concluídas
    var completionRate: String {
        guard self.count > 0 else { return "0%" }
        
        let totalTask = self.count
        let completed = self.completedTasks.count
        let rate = Double(completed) / Double(totalTask)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: rate)) ?? "0%"
    }
    
    // Retornar todas as tarefas concluidas nesta semana
    func completedThisWeek() -> [Task] {
        let now = Date()
        let startOfWeek = Date.startOfWeek(date: now)
        let endOfWeek = Date.endOfWeek(date: now)
        
        return completedTasks.filter { task in
            if let date = task.completeDate {
                return date >= startOfWeek && date <= endOfWeek
            }
            
            return false
        }
    }
    
    // Retorna todas as tarefas concluidas neste mês
    func completedThisMonth() -> [Task] {
            let calendar = Calendar.current
            let now = Date()
//            let range = calendar.range(of: .day, in: .month, for: now)!
            let components = calendar.dateComponents([.year, .month], from: now)
            
            let startOfMonth = calendar.date(from: components)!
            let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            
            return completedTasks.filter { task in
                if let date = task.completeDate {
                    return date >= startOfMonth && date <= startOfNextMonth
                }
                return false
            }
        }
    
    // Agrupa tarefas concluídas por dia da semana
    func completedGroupedByWeekday() -> [String: Int] {
        let formmater = DateFormatter()
        formmater.locale = Locale.current
        formmater.dateFormat = "E"
        
        var dict: [String: Int] = [:]
        
        for task in completedThisWeek() {
            if let date = task.completeDate {
                let key = formmater.string(from: date)
                dict[key, default: 0] += 1
            }
        }
        
       return dict
    }
    
    // Agrupa tarefas concluídas por mes
    func completeGroupedByMonth() -> [String: Int] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM"
        
        var dict: [String: Int] = [:]
        
        for task in completedTasks {
            if let date = task.completeDate {
                let key = formatter.string(from: date)
                dict[key, default: 0] += 1
            }
        }
        
        return dict
    }
}
