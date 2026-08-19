//
//  FileBubble.swift
//  Shaman
//
//  Created by winston on 8/18/26.
//

import AppKit
import CryptoKit
import SwiftUI

struct FileBubble: View {
    @Environment(\.theme) private var theme
    private var cornerRadius: CGFloat = 10

    @State private var digest: String = ""
    @State private var oops = false
    @State private var progress: Double = 0
    @State private var done: Bool = false

    @State private var digestHovered: Bool = false
    @State private var copyHovered: Bool = false
    @State private var copied: Bool = false

    let file: DroppedFile
    @Binding var run: Bool

    private var bgColor: Color {
        if !run {
            return theme.color.bgBase
        } else {
            if oops {
                return theme.color.error
            } else if done {
                return theme.color.done
            }
        }
        return theme.color.bgBase
    }

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

            VStack(alignment: .leading, spacing: 3) {
                Text(file.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text(file.subtitle)
                    .font(.caption)
                    .foregroundStyle(theme.color.textMuted)
                    .lineLimit(1)
                    .truncationMode(.middle)

                if progress > 0 && progress < 1 {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .controlSize(.small)
                        .tint(theme.color.running)
                } else if progress == 1 && digest != "" {
                    HStack {
                        Text(digest)
                            .font(.body)
                            .foregroundStyle(theme.color.textMuted)
                            .lineLimit(1)
                            .padding(.top, 3)

                        if digestHovered {
                            Image(
                                systemName: copied
                                    ? "checkmark" : "document.on.document"
                            )
                            .padding(5)
                            .imageScale(.medium)
                            .foregroundStyle(theme.color.textMuted)
                            .transition(.scale.combined(with: .opacity))
                            .onHover { hovering in
                                withAnimation {
                                    if !hovering {
                                        copied = false
                                    }
                                    copyHovered = hovering
                                }
                            }
                            .background {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .foregroundStyle(
                                        copyHovered
                                            ? theme.color.done
                                            : .clear
                                                .opacity(0.375)
                                    )

                            }
                            .onTapGesture {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(digest, forType: .string)
                                withAnimation {
                                    copied = true
                                }
                            }
                        }
                    }

                }
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bgColor, in: .rect(cornerRadius: cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(theme.color.bgSurface)
        }
        .contentShape(.rect(cornerRadius: cornerRadius))
        .onHover { hovering in
            withAnimation(.interpolatingSpring) {
                digestHovered = hovering
            }
        }
        .task(id: run) {
            guard run else { return }
            progress = 0
            do {
                let d = try await FileHasher(file: file).hash {
                    progress = $0
                }
                digest = d.map { String(format: "%02x", $0) }.joined()
                done = true
            } catch is CancellationError {
            } catch {
                oops = true
            }
        }
    }

}
