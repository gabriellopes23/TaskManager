//
//  RecurringTaskManager.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 28/09/25.
//

import Foundation
import SwiftData

class RecurringTaskManager {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func generateRecurringTasks() {
        let today = Calendar.current.startOfDay(for: Date())
        
        do {
            // 1. Buscar tarefas recorrentes que precisam de novas instâncias
            // Usamos repeatOptionsRawValue para compatibilidade com Predicate do SwiftData
            // Comparar diretamente com a string literal "Nunca" para evitar problemas de validação do Predicate
            let predicate = #Predicate<Task> {
                $0.repeatOptionRawValue != "Nunca" && $0.nextOccurrenceDate <= today
            }
            
            let descriptor = FetchDescriptor(predicate: predicate)
            let overdueRecurringTasks = try modelContext.fetch(descriptor)
            
            for task in overdueRecurringTasks {
                // Apenas gere uma nova instância se a tarefa original não estiver completa,
                // sua data de criação for anterior ou igual a hoje, e não for uma instância recorrente.
                // Isso evita a duplicação de lógica e garante que apenas a 'tarefa mãe' gere novas.
                if !task.isComplete && task.creationDate <= today && !task.isRecurringInstance {
                    if let nextTask = task.generateNextOccurrence() {
                        modelContext.insert(nextTask)
                        print("Gerada nova instância para: \(task.taskTitle) em \(nextTask.creationDate)")
                    }
                    
                    // Atualiza a tarefa original (ou a última instância da série) para a próxima ocorrência.
                    // Isso simula o comportamento de 'avançar' a tarefa no tempo.
                    task.creationDate = Task.calculateNextOccurrence(for: task.creationDate, repeatOption: task.repeatOptions)
                    task.nextOccurrenceDate = Task.calculateNextOccurrence(for: task.creationDate, repeatOption: task.repeatOptions)
                    task.isComplete = false // A tarefa 'mãe' é sempre a próxima a ser feita
                    
                    print("Tarefa original \(task.taskTitle) atualizada para a próxima ocorrência em \(task.creationDate)")
                }
            }
            
            try modelContext.save()
        } catch {
            print("Erro ao gerar tarefas recorrentes: \(error.localizedDescription)")
        }
    }
    
    func setupRecurringTaskGeneration() {
        generateRecurringTasks()
    }
}

