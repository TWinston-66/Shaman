//
//  Theme.swift
//  Shaman
//
//  Created by winston on 8/18/26.
//
import SwiftUI

struct Theme: Sendable {
    let color: Colors
}

struct Colors: Sendable {
    let bgBase: Color
    let bgSurface: Color
    let textPrimary: Color
    let textMuted: Color
    let primary: Color
    let border: Color
    let running: Color
    let done: Color
    let error: Color
}

extension Theme {
    static let `default` = Theme(
        color: .init(
            bgBase:      .teal.opacity(0.12),
            bgSurface:   .teal.opacity(0.35),
            textPrimary: .white,
            textMuted:   .white.opacity(0.6),
            primary:     .teal,
            border:      .teal.opacity(0.5),
            running:     .orange,
            done:        .green.opacity(0.5),
            error:       .red.opacity(0.5)
        )
    )
}
