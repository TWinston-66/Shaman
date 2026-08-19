//
//  BubbleInfo.swift
//  Shaman
//
//  Created by winston on 8/19/26.
//

import SwiftUI

struct BubbleInfo: View {
    
    @Environment(\.theme) private var theme
    
    @Binding var file: DroppedFile
    @Binding var algorithm: HashAlgorithm
    @Binding var run: Bool
    @Binding var autoAlgo: Bool
    var subtitle: String
    
    var body: some View {
        Text(file.name)
            .font(.body.weight(.medium))
            .lineLimit(1)
            .truncationMode(.middle)

        Text(subtitle)
            .font(.caption)
            .foregroundStyle(theme.color.textMuted)
            .lineLimit(1)
            .truncationMode(.middle)

        if (file.request.mode == .check) && (!run) {
            TextField(
                "",
                text: $file.request.compareHex,
                prompt: Text("expected hash")
            )
            .onChange(of: file.request.compareHex) {
                var normalizedHex: String {
                    (file.request.compareHex.split(
                        whereSeparator: \.isWhitespace
                    ).first?
                    .split(separator: ":").last).map(String.init)?
                    .lowercased() ?? ""
                }

                var inferredAlgorithm: HashAlgorithm? {
                    guard normalizedHex.allSatisfy(\.isHexDigit) else {
                        return nil
                    }
                    return HashAlgorithm(
                        hexDigestLength: normalizedHex.count
                    )
                }
                guard inferredAlgorithm != nil else { return }

                withAnimation {
                    algorithm = inferredAlgorithm!
                    autoAlgo = true
                }

            }
            .transition(.opacity.combined(with: .move(edge: .top)))

        }
    }
}

