//
//  EditTaskView.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 25/09/25.
//

import SwiftUI
import SwiftData

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @Bindable var task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // Botão de Fechar
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .tint(.red)
            }
            .hSpacing(.leading)
            
            // Campo título
            VStack(alignment: .leading, spacing: 8) {
                Text("Task Title")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Go for a Walk!", text: $task.taskTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(
//                        .quaternary.shadow(.drop(color: .black.opacity(0.25), radius: 2)),
//                        in: .rect(cornerRadius: 10)
                    )
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 5)
            
            // Data + Cor
            HStack(spacing: 12) {
                
                // Data
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Date")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    DatePicker("", selection: $task.creationDate)
                        .datePickerStyle(.compact)
                        .scaleEffect(0.9, anchor: .leading)
                }
                .padding(.top, 5)
                .padding(.trailing, -15)
                
                // Cor
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Color")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    let colors: [String] = ["colorYellow", "colorBlue", "colorGray", "colorGreen", "colorRed"]
                    
                    HStack(spacing: 0) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(color))
                                .frame(width: 20, height: 20)
                                .background {
                                    Circle()
                                        .stroke(lineWidth: 2)
                                        .opacity(task.tintColor == color ? 1 : 0)
                                }
                                .hSpacing(.center)
                                .contentShape(.rect)
                                .onTapGesture {
                                    task.tintColor = color
                                }
                        }
                    }
                }
                .padding(.top, 5)
            }
            .padding(.top, 5)
            
            Spacer(minLength: 0)
            
            // Botão salvar alterações
            Button(action: {
                do {
                    try context.save() // apenas salva alterações
                    dismiss()
                } catch {
                    print(error.localizedDescription)
                }
            }) {
                Text("Save Changes")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .textScale(.secondary)
                    .foregroundStyle(.black)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(Color(task.tintColor), in: .rect(cornerRadius: 10))
            }
            .disabled(task.taskTitle.isEmpty)
            .opacity(task.taskTitle.isEmpty ? 0.5 : 1)
        }
        .padding(15)
    }
}


#Preview {
    EditTaskView(task: Task(id: .init(), taskTitle: "", creationDate: .init(), isComplete: false, tint: ""))
}
