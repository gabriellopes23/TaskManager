//
//  Repeat.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 26/09/25.
//

import Foundation
import SwiftData

enum Repeat: String, Codable, CaseIterable {
    case nunca = "Nunca"
    case diaria = "Diariamente"
    case semanal = "Semanalmente"
    case mensal = "Mensalmente"
    
    var icon: String {
        switch self {
        case .nunca: return ""
        case .diaria: return "📅"
        case .semanal: return "🗓️"
        case .mensal: return "📆"
        }
    }
}
