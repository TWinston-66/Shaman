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
    private let cornerRadius: CGFloat = 10

    @State private var digest: String = ""
    @State private var oops = false
    @State private var progress: Double = 0
    @State private var done: Bool = false
    @State private var elapsed: Duration?

    @State private var digestHovered: Bool = false
    @State private var cancelHovered: Bool = false

    @State private var algorithm: HashAlgorithm = .default
    @State private var autoAlgo: Bool = false

    @Binding var file: DroppedFile
    @Binding var run: Bool
    @Binding var jobCancel: Bool
    var onRemove: () -> Void
    
    @State private var running: Bool = false
    @State private var cancel: Bool = false

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

    private var showsRemoveButton: Bool {
        digestHovered && !file.done
    }

    private var matches: Bool {
        file.request.compareHex.trimmingCharacters(in: .whitespacesAndNewlines)
            .caseInsensitiveCompare(digest) == .orderedSame
    }

    private var borderColor: Color {
        if run {
            if oops {
                return theme.color.errorBorder
            } else if done {
                return theme.color.doneBorder
            }
        }
        return theme.color.bgSurface
    }

    private var subtitle: String {
        if file.done, let elapsed {
            let dur = elapsed.formatted(
                .units(allowed: [.seconds, .milliseconds], width: .narrow)
            )
            return "\(file.subtitle) · \(dur)"
        }
        else if cancel {
            return "\(file.subtitle) · canceled"
        }
        return file.subtitle
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

                BubbleInfo(
                    file: $file,
                    algorithm: $algorithm,
                    run: $run,
                    autoAlgo: $autoAlgo,
                    subtitle: subtitle
                )

                if progress > 0 && progress < 1 {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .controlSize(.small)
                        .tint(theme.color.running)
                } else if progress == 1 && digest != "" {

                    BubbleResults(
                        file: $file,
                        algorithm: $algorithm,
                        run: $run,
                        digest: $digest,
                        digestHovered: $digestHovered,
                        matches: matches,
                        cornerRadius: cornerRadius
                    )
                    .padding(.top, 3)

                }
            }

            Spacer()

            BubbleForm(
                file: $file,
                algorithm: $algorithm,
                run: $run,
                autoAlgo: $autoAlgo
            )

            Button(
                action: {
                    if !run {
                        onRemove()
                    } else {
                        running = false
                        cancel = true
                        oops = true
                        jobCancel = true
                        file.done = true
                    }
                },
                label: {
                    Image(systemName: "xmark.octagon")
                        .padding(3)
                        .imageScale(.large)
                        .foregroundStyle(.red)
                        .background {
                            RoundedRectangle(
                                cornerRadius: cornerRadius
                            )
                            .foregroundStyle(
                                cancelHovered
                                    ? theme.color.bgSurface.opacity(0.375)
                                    : .clear
                            )

                        }
                }
            )
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation {
                    cancelHovered = hovering
                }
            }
            .padding(.leading, -5)
            .opacity(showsRemoveButton ? 1 : 0)
            .allowsHitTesting(showsRemoveButton)
        }
        .padding(10)
        .frame(alignment: .leading)
        .frame(maxWidth: .infinity)
        .background(bgColor, in: .rect(cornerRadius: cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(borderColor)
        }
        .contentShape(.rect(cornerRadius: cornerRadius))
        .onHover { hovering in
            withAnimation {
                digestHovered = hovering
            }
        }
        .animation(.default, value: file.request.mode)
        .onChange(of: run) {
            if run { running = true }
        }
        .task(id: running) {
            guard running && run else {
                progress = 0
                digest = ""
                done = false
                return
            }
            progress = 0
            elapsed = nil
            let clock = ContinuousClock()
            let start = clock.now
            do {
                let d = try await FileHasher(
                    file: file,
                    algorithm: algorithm
                ).hash {
                    progress = $0
                }
                guard !Task.isCancelled, run else { return }
                elapsed = clock.now - start
                digest = d.hex
                done = true
                file.done = true
            } catch is CancellationError {
            } catch {
                guard !Task.isCancelled, run else { return }
                oops = true
                file.done = true
            }
        }
    }

}
