//
//  Task.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 23/09/25.
//

import SwiftUI

// MARK: - Task Model
struct Task: Identifiable {
    var id: UUID = .init()
    var taskTitle: String
    var creationDate: Date = .init()
    var isComplete: Bool = false
    var tint: Color
}

// MARK: - Exemplo de Tarefas
var sampleTasks: [Task] = [
    .init(taskTitle: "Record Video", creationDate: .updateHour(-5), isComplete: true, tint: .blue),
    .init(taskTitle: "Redesign Website", creationDate: .updateHour(-3), tint: .red),
    .init(taskTitle: "Go for a Walk", creationDate: .updateHour(-5), tint: .pink),
    .init(taskTitle: "Edit Video", creationDate: .updateHour(-5), isComplete: true, tint: .yellow),
    .init(taskTitle: "Tweet about new Video!", creationDate: .updateHour(-5), tint: .gray),
]

// MARK: - Extension Date
extension Date {
    static func updateHour(_ value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: value, to: .init()) ?? .init()
    }
}
