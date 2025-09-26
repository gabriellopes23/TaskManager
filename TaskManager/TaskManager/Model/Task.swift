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
    var creationDate: Date
    var isComplete: Bool = false
    var tint: String
    
    init(id: UUID = .init(), taskTitle: String, creationDate: Date = .init(), isComplete: Bool = false, tint: String) {
        self.id = id
        self.taskTitle = taskTitle
        self.creationDate = creationDate
        self.isComplete = isComplete
        self.tint = tint
    }
    
    var tintColor: Color {
        switch tint {
        case "colorBlue": return .colorBlue
        case "colorYellow": return .colorYellow
        case "colorGreen": return .colorGreen
        case "colorGray": return .colorGray
        case "colorRed": return .colorRed
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
