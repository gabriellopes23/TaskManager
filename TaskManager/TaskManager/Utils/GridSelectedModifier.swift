//
//  GridSelectedModifier.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 26/09/25.
//

import SwiftUI

struct GridSelectedModifier: ViewModifier {
    
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(color, in: .rect(cornerRadius: 10))
    }
}
