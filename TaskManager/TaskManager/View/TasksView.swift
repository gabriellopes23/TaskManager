//
//  TaskView.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 25/09/25.
//

import SwiftUI
import SwiftData

struct TasksView: View {
    
    @Binding var currentDate: Date
    @Binding var searchTask: String
    
    // SwiftDat Dynamic Query
    @Query private var tasks: [Task]
    
    init(currentDate: Binding<Date>, searchTask: Binding<String>) {
        self._currentDate = currentDate
        self._searchTask = searchTask
        
        // Predicate
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: currentDate.wrappedValue)
        let endOfDate = calendar.date(byAdding: .day, value: 1, to: startOfDate)!
        let predicate = #Predicate<Task> {
            return $0.creationDate >= startOfDate && $0.creationDate < endOfDate
        }
        // Sorting
        let sortDescriptor = [
            SortDescriptor(\Task.creationDate, order: .forward)
        ]
        self._tasks = Query(filter: predicate, sort: sortDescriptor, animation: .snappy)
    }
    
    var filteredTasks: [Task] {
        if searchTask.isEmpty {
            return tasks
        } else {
            return tasks.filter { $0.taskTitle.localizedCaseInsensitiveContains(searchTask) }
        }
    }
    
    var body: some View {
        if tasks.isEmpty {
            ContentUnavailableView {
                Image(systemName: "clipboard")
                    .padding()
                    .background(.colorGrid, in: .circle)
                Text("Nenhuma Tarefa para Hoje")
                    .font(.headline)
                Text("Toque no + para criar uma nova tarefa")
                    .font(.caption)
            }
            .foregroundStyle(.gray)
        } else {
            VStack(alignment: .leading) {
                ForEach(filteredTasks) { task in
                    TaskRowView(task: task)
                }
            }
            .padding()
        }
    }
}

#Preview {
    TasksView(currentDate: .constant(.init()), searchTask: .constant(""))
}
