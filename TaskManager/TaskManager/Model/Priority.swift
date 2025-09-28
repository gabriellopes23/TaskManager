//
//  Priority.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 26/09/25.
//

import Foundation
import SwiftData


enum Priority: String, Codable, CaseIterable {
    case baixa = "Baixa"
    case media = "Média"
    case alta = "Alta"
    
    var icon: String {
        switch self {
        case .baixa: return "🟢"
        case .media: return "🟡"
        case .alta: return "🔴"
        }
    }
}
