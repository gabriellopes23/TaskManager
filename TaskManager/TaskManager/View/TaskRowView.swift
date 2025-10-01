//
//  TaskRowView(New).swift
//  TaskManager
//
//  Created by Gabriel Lopes on 27/09/25.
//

import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Bindable var task: Task
    
    @Environment(\.modelContext) var context
    
    @State private var showEditTask: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var position: CGSize = .zero
    @State private var isHorizontalDrag: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            
            RoundedRectangle(cornerRadius: 10)
                .fill(task.tintColor)
                .frame(width: 10, height: 50)
                .vSpacing(.center)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(task.taskTitle)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.colorTextForm)
                    .opacity(task.isComplete ? 0.8 : 1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                
                HStack {
                    Label(task.creationDate.format("hh:mm a"), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    Circle()
                        .fill(.gray)
                        .frame(width: 4, height: 4)
                    
                    Label(title: { Text(task.category.rawValue) }, icon: { Text(task.category.icon) })
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    Circle()
                        .fill(.gray)
                        .frame(width: 4, height: 4)
                    
                    Label(task.repeatOptionRawValue, systemImage: "arrow.trianglehead.counterclockwise")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                }
                
                Text(task.taskDescription ?? "")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
            }
            
            Spacer()
            
            Text(task.priority.icon)
                .font(.caption2)
                .opacity(0.8)
        }
        .padding(15)
        .hSpacing(.leading)
        .background(.colorGrid, in: .rect(cornerRadius: 16))
        .strikethrough(task.isComplete, pattern: .solid, color: .black)
        .opacity(task.isComplete ? 0.9 : 1)
        .contentShape(Rectangle())
        .offset(x: dragOffset.width + position.width)
        .animation(.linear, value: dragOffset)
        .simultaneousGesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onChanged { value in
                    // Verifica se já decidiu a direção
                    if !isHorizontalDrag {
                        // Decide se é horizontal ou vertical
                        if abs(value.translation.width) > abs(value.translation.height) {
                            isHorizontalDrag = true
                        } else {
                            // É vertical → não intercepta
                            isHorizontalDrag = false
                            return
                        }
                    }
                    
                    if isHorizontalDrag {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    if isHorizontalDrag {
                        if dragOffset.width > 40 {
                            position.width = 120
                        } else if dragOffset.width < -40 {
                            position.width = -170
                        } else {
                            position.width = 0
                        }
                    }
                    
                    // Reseta
                    dragOffset = .zero
                    isHorizontalDrag = false
                }
        )
        .background(alignment: .leading, content: {
            SwipeButtonsActions(action: {
                withAnimation(.linear) {
                    task.isComplete.toggle()
                    dragOffset = .zero
                    position = .zero
                    task.updateNotication()
                }
                
                if task.isComplete {
                    task.completeDate = Date()
                } else {
                    task.completeDate = nil
                }
                
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
            }, image: "checkmark", title: "Concluir", color: .green)
            
        })
        .background(alignment: .trailing, content: {
            HStack {
                SwipeButtonsActions(action: {
                    showEditTask.toggle()
                }, image: "pencil.line", title: "Editar", color: .blue)
                
                SwipeButtonsActions(action: {
                    do {
                        context.delete(task)
                        try context.save()
                        task.cancelTaskNotification()
                    } catch {
                        print("Não foi possivel deletar a task: \(error.localizedDescription)")
                    }
                }, image: "trash", title: "Deletar", color: .red)
                
            }
            
        })
        .sheet(isPresented: $showEditTask) {
            TaskFormView(task: task)
                .presentationDetents([.fraction(0.9)])
        }
        
    }
}

// MARK: - SwipeButtonsActions
extension TaskRowView {
    @ViewBuilder
    func SwipeButtonsActions(action: @escaping () -> Void, image: String, title: String, color: Color) -> some View{
        Button(action: {
            action()
        }) {
            Image(systemName: image)
            Text(title)
        }
        .font(.subheadline)
        .fontWeight(.bold)
        .foregroundStyle(color)
    }
}

#Preview {
    ContentView()
}
