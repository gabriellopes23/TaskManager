//
//  OffsetKey.swift
//  TaskManager
//
//  Created by Gabriel Lopes on 24/09/25.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
