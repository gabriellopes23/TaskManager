//
//  TaskRowView.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 24/09/25.
//

import SwiftUI
import SwiftData

struct TaskRowView: View {
    
    @Bindable var task: Task
    
    @Environment(\.modelContext) var context
    
    @State private var showEditTask: Bool = false
    
    var indicatorColor: Color {
        if task.isComplete {
            return .green
        }
        
        return task.creationDate.isSameHour ? .blue : (task.creationDate.isPastHour ? .red : .black)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 10, height: 10)
                .padding(4)
                .background(.white.shadow(.drop(color: .black.opacity(0.1), radius: 3)), in: .circle)
                .overlay {
                    Circle()
                        .foregroundStyle(.clear)
                        .contentShape(.circle)
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            withAnimation(.snappy) {
                                task.isComplete.toggle()
                            }
                        }
                }
                
            
            VStack(alignment: .leading, spacing: 8) {
                Text(task.taskTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(.background)
                
                Label(task.creationDate.format("hh:mm a"), systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.background)
            }
            .padding(15)
            .hSpacing(.leading)
            .background(task.tintColor, in: .rect(topLeadingRadius: 15, bottomLeadingRadius: 15))
            .strikethrough(task.isComplete, pattern: .solid, color: .black)
            .onTapGesture {
                showEditTask.toggle()
            }
            .contentShape(.contextMenuPreview, .rect(cornerRadius: 15))
            .contextMenu {
                Button("Delete Task", role: .destructive) {
                    context.delete(task)
                    try? context.save()
                }
            }
            .offset(y: -8)
            .sheet(isPresented: $showEditTask) {
                EditTaskView(task: task)
                    .presentationDetents([.height(300)])
                    .interactiveDismissDisabled()
                    .presentationBackground(.tertiary)
            }
        }
    }
}

#Preview {
    ContentView()
}
