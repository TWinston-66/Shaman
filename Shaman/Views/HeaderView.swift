//
//  HeaderView.swift
//  Shaman
//
//  Created by winston on 8/19/26.
//

import SwiftUI

struct HeaderView: View {
    @Environment(\.theme) private var theme

    let version: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("Shaman")
                .font(.system(.title2, design: .rounded).weight(.semibold))
                .foregroundStyle(theme.color.textPrimary)
                //.padding(.leading, 20)

            Text(version)
                .font(.caption2.weight(.medium).monospacedDigit())
                .foregroundStyle(theme.color.textMuted)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(theme.color.bgSurface.opacity(0.5), in: .capsule)
                .overlay {
                    Capsule().strokeBorder(theme.color.border.opacity(0.6))
                }
            
        }
        .frame(height: 45)
        .frame(minWidth: 500)
        .frame(maxWidth: .infinity)
        .background {
            LinearGradient(
                colors: [theme.color.bgSurface.opacity(0.35), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
    }
}
