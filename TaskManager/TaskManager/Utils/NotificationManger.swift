//
//  NotificationManger.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 29/09/25.
//

import Foundation
import UserNotifications

class NotificationManger: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManger()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Solicitar Permissão de Notificação
    /*
     Este Método solicita ao usuário a permissão para enviar notificações.
     Deve ser chamado quando o aplicativo é aberto pela primera vez ou em um momento oportuno para o usuário.
     */
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Permissão de notificação Concedida.")
            } else if let error = error {
                print("Erro ao solicitar permissão de notificação: \(error.localizedDescription)")
            } else {
                print("Permissão negada!")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    /*
     Este método é chamado quando uma notificação é entregue ao aplicativo enquanto está em primeiro plano.
     Por padrão, as notificações não são exibidas quando o app está ativo, a menos que chame o completionHandler
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    // MARK: - Agendar Notificação
    /*
     Este método agenda uma notificação local para um tarefa específica
     Ele utiliza os detalhes da tarefa para criar o conteúdo e o gatilho da notificação
     */
    func scheduleNotification(for task: Task) {
        // 1. Conteúdo da Notificação
        // Define o título, subtítulo e corpo da notificação.
        let content = UNMutableNotificationContent()
        content.title = task.taskTitle
        content.body = task.taskDescription ?? "Nenhuma Descrição disponível."
        content.sound = .default
        content.userInfo = ["taskID": task.id.uuidString]
        
        // 2. Gatilho da Notificação
        // O gatilho determina quando a notificação será apresentada.
        // Para tarefas, usaremos um gatilho baseado em calendário (data e hora).
        let calendar = Calendar.current
        var dateComponents: DateComponents
        var repeats = false
        
        // A data base para o agendamento será a nextOccurrenceDate para tarefas recorrents
        // e a creationDate para tarefas não recorrentes
        let scheduleDate = (task.repeatOptions != .nunca) ? task.nextOccurrenceDate : task.creationDate
        
        switch task.repeatOptions {
        case .nunca:
            repeats = false
            dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: scheduleDate)
        case .diaria:
            repeats = true
            dateComponents = calendar.dateComponents([.hour, .minute, .second], from: scheduleDate)
        case .semanal:
            repeats = true
            dateComponents = calendar.dateComponents([.weekday, .hour, .minute, .second], from: scheduleDate)
        case .mensal:
            repeats = true
            dateComponents = calendar.dateComponents([.day, .hour, .minute, .second], from: scheduleDate)
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        
        // 3. Requisição da Notificação
        // Criar uma requisição única para a notificação,
        // O identificador deve ser único para cada notificação, permitindo cancelamento ou atualização
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        // 4. Agendar Notificação
        // Adiciona a requisição ao centro de notificações para agendamento
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error ao agendar notificação para \(task.taskTitle): \(error.localizedDescription)")
            } else {
                print("Notificação agendada com sucesso para \(task.taskTitle)")
            }
        }
    }
    
    // MARK: - Cancelar Notifications
    // Este método cancela uma notificação usando seu identificador
    func cancelNotification(for taskID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskID.uuidString])
        print("Notificação com ID \(taskID.uuidString) cancelada")
    }
    
    // MARK: - Listar Notifications Pendentes (Depuração)
    func listPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            if requests.isEmpty {
                print("Nenhuma Notificação pendente")
            } else {
                for request in requests {
                    print("- ID: \(request.identifier), Título: \(request.content.title), Gatilho: \(String(describing: request.trigger))")
                }
            }
        }
    }
}
