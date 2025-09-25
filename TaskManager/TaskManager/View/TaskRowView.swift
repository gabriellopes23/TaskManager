//
//  TaskRowView.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 24/09/25.
//

import SwiftUI

struct TaskRowView: View {
    
    @Binding var task: Task
    
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
                        .frame(width: 50, height: 50)
                        .blendMode(.destinationOver)
                }
                .onTapGesture {
                    withAnimation(.snappy) {
                        task.isComplete.toggle()
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
            .background(task.tint, in: .rect(topLeadingRadius: 15, bottomLeadingRadius: 15))
            .strikethrough(task.isComplete, pattern: .solid, color: .black)
            .offset(y: -8)
        }
    }
}

#Preview {
    ContentView()
}
