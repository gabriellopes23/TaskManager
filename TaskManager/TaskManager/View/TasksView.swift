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
    @Binding var categoryFilter: String
    
    // SwiftDat Dynamic Query
    @Query private var tasks: [Task]
    
    init(currentDate: Binding<Date>, searchTask: Binding<String>, categoryFilter: Binding<String>) {
        self._currentDate = currentDate
        self._searchTask = searchTask
        self._categoryFilter = categoryFilter
        
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
        tasks.filter { task in
            let matchesSearch = searchTask.isEmpty || task.taskTitle.localizedCaseInsensitiveContains(searchTask)
            let matchesCategory = categoryFilter.isEmpty || task.category.rawValue.contains(categoryFilter)
            
            return matchesSearch && matchesCategory
        }
        .sorted {
            if $0.isComplete == $1.isComplete {
                return $0.creationDate < $1.creationDate
            }
            return !$0.isComplete && $1.isComplete
        }
    }
    
    var body: some View {
        if tasks.isEmpty {
            ContentUnavailableView {
                Image(systemName: "clipboard")
                    .padding()
                    .font(.title)
                    .fontWeight(.bold)
                    .background(.colorGrid, in: .circle)
                Text("Nenhuma Tarefa para Hoje")
                    .font(.headline)
                Text("Toque no + para criar uma nova tarefa")
                    .font(.footnote)
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
    TasksView(currentDate: .constant(.init()), searchTask: .constant(""), categoryFilter: .constant(""))
}
