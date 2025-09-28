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
                    .foregroundStyle(.white)
                
                HStack {
                    Label(task.creationDate.format("hh:mm a"), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    Circle()
                        .fill(.gray)
                        .frame(width: 4, height: 4)
                    
                    Label(title: { Text(task.category.name) }, icon: { Text(task.category.icon) })
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                }
                
                Text(task.taskDescription ?? "")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
            }
        }
        .padding(15)
        .hSpacing(.leading)
        .background(.colorGrid, in: .rect(cornerRadius: 16))
        .strikethrough(task.isComplete, pattern: .solid, color: .black)
        .overlay(content: {
            RoundedRectangle(cornerRadius: 16)
                .fill(.colorGrid.opacity(task.isComplete ? 0.5 : 0))
        })
        .contentShape(Rectangle())
        .offset(x: dragOffset.width + position.width)
        .animation(.linear, value: dragOffset)
        .gesture(
            DragGesture()
                .onChanged({ value in
                    dragOffset = value.translation
                })
                .onEnded({ value in
                    if dragOffset.width > 40 {
                        position.width = 120
                    } else if dragOffset.width < -40 {
                        position.width = -170
                    } else {
                        position.width = 0
                    }
                    dragOffset = .zero
                })
        )
        .background(alignment: .leading, content: {
            SwipeButtonsActions(action: {
                withAnimation(.linear) {
                    task.isComplete.toggle()
                    dragOffset = .zero
                    position = .zero
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
