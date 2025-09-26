//
//  TaskManagerApp.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 23/09/25.
//

import SwiftUI
import SwiftData

@main
struct TaskManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Task.self)
    }
}
