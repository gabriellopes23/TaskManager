//
//  NewTaskView(NEW).swift
//  TaskManager
//
//  Created by Gabriel Lopes on 26/09/25.
//

import SwiftUI
import SwiftData

struct TaskFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @State private var taskDate: Date = .init()
    @State private var taskColor: String = "colorBlue"
    @State private var taskCategory: Category
    @State private var taskRepeat: Repeat
    @State private var taskPriority: Priority
    
    let colors: [String] = ["colorBlue", "colorGreen", "colorRed", "colorYellow", "colorPurple", "colorOrange"]
    let categories: [Category]
    let repeatOptions: [Repeat]
    let priorities: [Priority]
    
    var existingTask: Task?
    
    init(task: Task? = nil) {
        let defaultCategories: [Category] = [
            .trabalho, .estudo, .pessoal, .saude, .compras, .lazer
        ]
        let defaultRepeatOptions: [Repeat] = [
            .nunca, .diaria, .semanal, .mensal
        ]
        let defaultPriorities: [Priority] = [
            .baixa, .media, . alta
        ]
        
        self.categories = defaultCategories
        self.repeatOptions = defaultRepeatOptions
        self.priorities = defaultPriorities
        
        if let task = task {
            _taskTitle = State(initialValue: task.taskTitle)
            _taskDescription = State(initialValue: task.taskDescription ?? "")
            _taskDate = State(initialValue: task.creationDate)
            _taskColor = State(initialValue: task.tint)
            _taskCategory = State(initialValue: task.category)
            _taskRepeat = State(initialValue: task.repeatOptions)
            _taskPriority = State(initialValue: task.priority)
            self.existingTask = task
        } else {
            _taskCategory = State(initialValue:  defaultCategories[0])
            _taskRepeat = State(initialValue: defaultRepeatOptions[0])
            _taskPriority = State(initialValue: defaultPriorities[1])
            self.existingTask = nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HeaderView()
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    TitleDescriptionAndDate()
                    CategoryGrid()
                    ColorSelector()
                    RepeatOptionsGrid()
                    PriorityOptionsGrid()
                    CreateTaskButton()
                }
                .padding(.horizontal, 2)
            }
            .scrollIndicators(.hidden)
        }
        .padding()
        .vSpacing(.top)
        .hSpacing(.leading)
        .background(.BG)
    }
}

// MARK: - HeaderView
extension TaskFormView {
    @ViewBuilder
    private func HeaderView() -> some View {
        HStack {
            Text("Nova Tarefa")
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(.red)
                    .background {
                        Circle()
                            .fill(.red.opacity(0.3))
                            .frame(width: 35, height: 35)
                    }
                    .padding(.horizontal, 8)
            }
        }
        .padding(.horizontal, 2)
        .padding([.bottom], 10)
    }
}

// MARK: - TitleDescriptionAndDate
extension TaskFormView {
    @ViewBuilder
    private func TitleDescriptionAndDate() -> some View {
        Text("Título da Tarefa")
            .font(.headline)
        TextField("Estudar Algoritmo", text: $taskTitle)
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background(.colorGrid, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray, lineWidth: 1)
            }
        
        Text("Descrição (opcional)")
            .font(.headline)
        TextEditor(text: $taskDescription)
            .textEditorStyle(.plain)
            .frame(height: 100)
            .background(.colorGrid, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray, lineWidth: 1)
            }
        
        HStack {
            Text("Data e Horário")
                .font(.headline)
            DatePicker("", selection: $taskDate)
        }
    }
}

// MARK: - CategoryGrid
extension TaskFormView {
    @ViewBuilder
    private func CategoryGrid() -> some View {
        Text("Categoria")
            .font(.headline)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
            ForEach(categories, id: \.self) { category in
                Button(action: {
                    taskCategory = category
                }) {
                    VStack(spacing: 5) {
                        Text(category.icon)
                            .font(.largeTitle)
                        Text(category.rawValue)
                            .font(.headline)
                            .foregroundStyle(taskCategory == category ? .white : .colorTextForm)
                    }
                    .modifier(GridSelectedModifier(color: taskCategory == category ? .colorGridCategory : .colorGrid))
                }
            }
        }
    }
}

// MARK: - ColorSelector
extension TaskFormView {
    @ViewBuilder
    private func ColorSelector() -> some View {
        Text("Cor da Task")
            .font(.headline)
        HStack {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(Color(color))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                            .opacity(taskColor == color ? 1 : 0)
                        Circle()
                            .stroke(.colorTextForm, lineWidth: 2)
                            .opacity(taskColor == color ? 1 : 0)
                    }
                    .onTapGesture {
                        withAnimation(.snappy) {
                            taskColor = color
                        }
                    }
            }
        }
    }
}

// MARK: - RepeatOptionsGrid
extension TaskFormView {
    @ViewBuilder
    private func RepeatOptionsGrid() -> some View {
        Text("Repetição")
            .font(.headline)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
            ForEach(repeatOptions, id: \.self) { option in
                Button(action: {
                    taskRepeat = option
                }) {
                    HStack {
                        Text(option.icon)
                        Text(option.rawValue)
                            .font(.headline)
                            .foregroundStyle(taskRepeat == option ? .white : .colorTextForm)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                    }
                    .modifier(GridSelectedModifier(color: taskRepeat == option ? .colorGridRepeat : .colorGrid))
                }
            }
        }
    }
}

// MARK: - PriorityOptionsGrid
extension TaskFormView {
    @ViewBuilder
    private func PriorityOptionsGrid() -> some View {
        Text("Prioridade")
            .font(.headline)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
            ForEach(priorities, id: \.self) { priority in
                Button(action: {
                    taskPriority = priority
                }) {
                    HStack {
                        Text(priority.icon)
                            .font(.caption)
                        Text(priority.rawValue)
                            .font(.headline)
                            .foregroundStyle(taskPriority == priority ? .white : .colorTextForm)
                    }
                    .modifier(GridSelectedModifier(color: taskPriority == priority ? .colorGridPriority : .colorGrid))
                }
            }
        }
    }
}

// MARK: - CreateTaskButton
extension TaskFormView {
    @ViewBuilder
    private func CreateTaskButton() -> some View {
        Button(action: {
            if let task = existingTask {
                task.taskTitle = taskTitle
                task.taskDescription = taskDescription
                task.creationDate = taskDate
                task.tint = taskColor
                task.category = taskCategory
                task.repeatOptions = taskRepeat
                task.priority = taskPriority
            } else {
                let newTask = Task(
                    taskTitle: taskTitle,
                    taskDescription: taskDescription,
                    creationDate: taskDate,
                    tint: taskColor,
                    category: taskCategory,
                    repeatOptions: taskRepeat,
                    priority: taskPriority,
                    parentTaskID: nil,
                    isRecurringInstance: false
                )
                context.insert(newTask)
            }
            
            do {
                try context.save()
                dismiss()
            } catch {
                print("Não foi possivel salvar a Task: \(error.localizedDescription)")
            }
        }) {
            Text(existingTask == nil ? "Create Task" : "Salvar Alterações")
                .font(.title3)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .foregroundStyle(.white)
                .hSpacing(.center)
                .padding(.vertical, 15)
                .background(.blue, in: .rect(cornerRadius: 10))
        }
        .hSpacing(.center)
    }
}

#Preview {
    TaskFormView()
}
