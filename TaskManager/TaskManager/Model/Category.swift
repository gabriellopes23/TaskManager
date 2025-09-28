//
//  Category.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 26/09/25.
//

import Foundation
import SwiftData

enum Category: String, CaseIterable, Codable {
    case trabalho = "Trabalho"
    case estudo = "Estudos"
    case pessoal = "Pessoal"
    case saude = "Saúde"
    case compras = "Compras"
    case lazer = "Lazer"
    
    var icon: String {
        switch self {
        case .trabalho: return "💼"
        case .estudo: return "📚"
        case .pessoal: return "👤"
        case .saude: return "❤️"
        case .compras: return "🛒"
        case .lazer: return "🎮"
        }
    }
}




