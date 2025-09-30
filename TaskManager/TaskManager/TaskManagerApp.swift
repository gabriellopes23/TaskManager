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
    let sharedModelContainer: ModelContainer
    
    init() {
        NotificationManger.shared.requestAuthorization()
        
        do {
            sharedModelContainer = try ModelContainer(for: Task.self)
            
            let recurringTaskManager = RecurringTaskManager(modelContext: sharedModelContainer.mainContext)
            recurringTaskManager.generateRecurringTasks()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Task.self)
    }
}
