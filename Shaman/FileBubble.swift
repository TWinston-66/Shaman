//
//  FileBubble.swift
//  Shaman
//
//  Created by winston on 8/18/26.
//
import SwiftUI

struct FileBubble: View {
    @Environment(\.theme) private var theme
    
    private var cornerRadius: CGFloat = 10
    
    let file: DroppedFile
    @Binding var run: Bool
    

    var body: some View {
        HStack(spacing: 10) {
            Image(
                nsImage: NSWorkspace.shared.icon(
                    forFile: file.path.path(percentEncoded: false)
                )
            )
            .resizable()
            .interpolation(.high)
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text(file.subtitle)
                    .font(.caption)
                    .foregroundStyle(theme.color.textMuted)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.color.bgBase, in: .rect(cornerRadius: cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(theme.color.bgSurface)
        }
        .contentShape(.rect(cornerRadius: cornerRadius))
    }
}
