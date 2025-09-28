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
    var repeatOptions: Repeat
    var priority: Priority
    
    init(id: UUID = .init(), taskTitle: String, taskDescription: String?, creationDate: Date = .init(), isComplete: Bool = false, tint: String, category: Category, repeatOptions: Repeat, priority: Priority) {
        self.id = id
        self.taskTitle = taskTitle
        self.taskDescription = taskDescription
        self.creationDate = creationDate
        self.isComplete = isComplete
        self.tint = tint
        self.category = category
        self.repeatOptions = repeatOptions
        self.priority = priority
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
}

// MARK: - Extension Date
extension Date {
    static func updateHour(_ value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: value, to: .init()) ?? .init()
    }
}


var DummyData: [Task] = [
    .init(taskTitle: "Programar Task Manager", taskDescription: "Task Manager", creationDate: .init(), isComplete: false, tint: "colorBlue", category: Category(name: "Estudos", icon: "📚"), repeatOptions: .nunca, priority: Priority(name: "Baixa", icon: "")),
    .init(taskTitle: "Programar", taskDescription: "Task Manager", creationDate: .init(), isComplete: false, tint: "colorPurple", category: Category(name: "Estudos", icon: "📚"), repeatOptions: .nunca, priority: Priority(name: "Baixa", icon: ""))
]
