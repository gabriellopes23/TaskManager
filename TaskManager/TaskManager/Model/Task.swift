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
    
    init(id: UUID = .init(), taskTitle: String, taskDescription: String?, creationDate: Date = .init(), isComplete: Bool = false, tint: String, category: Category, repeatOptions: Repeat, priority: Priority, parentTaskID: UUID? = nil, isRecurringInstance: Bool = false) {
        self.id = id
        self.taskTitle = taskTitle
        self.taskDescription = taskDescription
        self.creationDate = creationDate
        self.isComplete = isComplete
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
            isComplete: false, // Nova instância não está completa
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
}


var DummyData: [Task] = [
    .init(taskTitle: "Programar Task Manager", taskDescription: "Task Manager", creationDate: .init(), isComplete: false, tint: "colorBlue", category: .estudo, repeatOptions: .nunca, priority: .baixa),
    .init(taskTitle: "Programar", taskDescription: "Task Manager", creationDate: .init(), isComplete: false, tint: "colorPurple", category: .estudo, repeatOptions: .nunca, priority: .alta)
]
