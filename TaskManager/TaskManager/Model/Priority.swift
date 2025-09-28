//
//  Priority.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 26/09/25.
//

import Foundation
import SwiftData

@Model
class Priority {
    var name: String
    
    var icon: String
    
    init(name: String, icon: String) {
        self.name = name
        self.icon = icon
    }
}
