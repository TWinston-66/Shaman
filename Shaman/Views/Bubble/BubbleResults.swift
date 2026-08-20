//
//  BubbleResults.swift
//  Shaman
//
//  Created by winston on 8/19/26.
//

import SwiftUI

struct BubbleResults: View {
    
    @Environment(\.theme) private var theme
    
    @State private var copied: Bool = false
    @State private var copyHovered: Bool = false
    
    @Binding var file: DroppedFile
    @Binding var algorithm: HashAlgorithm
    @Binding var run: Bool
    @Binding var digest: String
    @Binding var digestHovered: Bool
   
    
    var matches: Bool
    let cornerRadius: CGFloat

    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {

                if file.request.mode == .check {
                    var compareText: String {
                        if file.request.mode == .check {
                            return "Expected: "
                                + file.request.compareHex
                        }
                        return file.request.compareHex
                    }

                    Text(compareText)
                        .font(.body.monospaced())
                        .foregroundStyle(theme.color.textMuted)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                HStack {

                    var gotText: String {
                        if file.request.mode == .check {
                            return "Got: " + digest
                        }
                        return digest
                    }

                    Text(gotText)
                        .font(.body.monospaced())
                        .foregroundStyle(theme.color.textMuted)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Image(
                        systemName: copied
                            ? "checkmark" : "document.on.document"
                    )
                    .padding(5)
                    .imageScale(.small)
                    .foregroundStyle(theme.color.textMuted)
                    .onHover { hovering in
                        withAnimation {
                            if !hovering {
                                copied = false
                            }
                            copyHovered = hovering
                        }
                    }
                    .background {
                        RoundedRectangle(
                            cornerRadius: cornerRadius
                        )
                        .foregroundStyle(
                            copyHovered
                                ? theme.color.bgSurface
                                : .clear
                                    .opacity(0.375)
                        )

                    }
                    .onTapGesture {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(
                            digest,
                            forType: .string
                        )
                        withAnimation {
                            copied = true
                        }
                    }
                    .opacity(digestHovered ? 1 : 0)
                    .allowsHitTesting(digestHovered)
                }

            }

            if file.request.mode == .check {
                Image(
                    systemName: matches
                        ? "checkmark.shield" : "xmark.shield"
                )
                .font(.system(size: 24, weight: .semibold))
                .padding(10)
                .foregroundStyle(
                    matches
                        ? theme.color.doneStrong
                        : theme.color.errorStrong
                )
                .contentTransition(.symbolEffect(.replace))
                .opacity(file.request.mode == .check ? 1 : 0)
            }

        }
    }
}

