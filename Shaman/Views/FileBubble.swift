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
    private static let cornerRadius: CGFloat = 10

    @State private var digest: String = ""
    @State private var oops = false
    @State private var progress: Double = 0
    @State private var done: Bool = false

    @State private var digestHovered: Bool = false
    @State private var copyHovered: Bool = false
    @State private var copied: Bool = false

    @Binding var file: DroppedFile
    @State private var hashRequest: HashRequest = HashRequest(compareHex: "", mode: .generate)
    @Binding var globalMode: ModeState

    private var bgColor: Color {
        if !globalMode.run {
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

    private var matches: Bool {
        hashRequest.compareHex.trimmingCharacters(in: .whitespacesAndNewlines)
            .caseInsensitiveCompare(digest) == .orderedSame
    }

    private var borderColor: Color {
        if globalMode.run {
            if oops {
                return theme.color.errorBorder
            } else if done {
                return theme.color.doneBorder
            }
        }
        return theme.color.bgSurface
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(
                nsImage: NSWorkspace.shared.icon(
                    forFile: file.path.path(percentEncoded: false)
                )
            )
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 5) {

                HStack {
                    Text(file.name)
                        .font(.body.weight(.medium))
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Picker("", selection: $hashRequest.mode) {
                        ForEach(Mode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                                .font(.caption)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(theme.color.textMuted)
                    .scaleEffect(0.8)
                    .disabled(globalMode.run)
                    .onChange(of: hashRequest.mode) {
                        if hashRequest.mode == .check {
                            
                                globalMode.mode = .check
                            
                            
                        }
                    }
                }

                Text(file.subtitle)
                    .font(.caption)
                    .foregroundStyle(theme.color.textMuted)
                    .lineLimit(1)
                    .truncationMode(.middle)

                if (hashRequest.mode == .check) && (!globalMode.run) {
                    TextField(
                        "",
                        text: $hashRequest.compareHex,
                        prompt: Text("hash")
                    )
                }

                if progress > 0 && progress < 1 {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .controlSize(.small)
                        .tint(theme.color.running)
                } else if progress == 1 && digest != "" {

                    HStack {
                        VStack(alignment: .leading, spacing: 5) {

                            if hashRequest.mode == .check {
                                var compareText: String {
                                    if hashRequest.mode == .check {
                                        return "Expected: "
                                            + hashRequest.compareHex
                                    }
                                    return hashRequest.compareHex
                                }

                                Text(compareText)
                                    .font(.body.monospaced())
                                    .foregroundStyle(theme.color.textMuted)
                                    .lineLimit(1)
                                    .fixedSize()
                            }

                            HStack {

                                var gotText: String {
                                    if hashRequest.mode == .check {
                                        return "Got: " + digest
                                    }
                                    return digest
                                }

                                Text(gotText)
                                    .font(.body.monospaced())
                                    .foregroundStyle(theme.color.textMuted)
                                    .lineLimit(1)
                                    .fixedSize()

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
                                    RoundedRectangle(cornerRadius: Self.cornerRadius)
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

                        if hashRequest.mode == .check {
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
                        }

                    }
                    .padding(.top, 3)

                }
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(alignment: .leading)
        .background(bgColor, in: .rect(cornerRadius: Self.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .strokeBorder(borderColor)
        }
        .contentShape(.rect(cornerRadius: Self.cornerRadius))
        .onHover { hovering in
            withAnimation() {
                digestHovered = hovering
            }
        }
        .task(id: globalMode) {
            guard globalMode.run else { return }
            progress = 0
            do {
                let d = try await FileHasher(
                    file: file,
                    algorithm: globalMode.algorithm
                ).hash {
                    progress = $0
                }
                digest = d.hex
                done = true
                file.done = true
            } catch is CancellationError {
            } catch {
                oops = true
                file.done = true
            }
        }
    }

}
