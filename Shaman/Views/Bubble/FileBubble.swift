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
    @State private var elapsed: Duration?

    @State private var digestHovered: Bool = false
    @State private var copyHovered: Bool = false
    @State private var copied: Bool = false

    @State private var algorithm: HashAlgorithm = .default
    @State private var autoAlgo: Bool = false

    @Binding var file: DroppedFile
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
        if file.done {
            let dur = elapsed!.formatted(
                .units(allowed: [.seconds, .milliseconds], width: .narrow)
            )
            return "\(file.subtitle) · \(dur)"
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

                if progress > 0 && progress < 1 {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .controlSize(.small)
                        .tint(theme.color.running)
                } else if progress == 1 && digest != "" {

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
                                    .fixedSize()
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
                                    RoundedRectangle(
                                        cornerRadius: Self.cornerRadius
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
                    .padding(.top, 3)

                }
            }

            Spacer()

            VStack(spacing: 5) {

                Picker("", selection: $file.request.mode) {
                    ForEach(Mode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                            .font(.caption)
                    }
                }
                .pickerStyle(.segmented)
                .tint(theme.color.textMuted)
                .scaleEffect(0.8)
                .disabled(run)

                HStack(spacing: 5) {
                    Menu {
                        ForEach(HashAlgorithm.allCases) { algo in
                            Button {
                                withAnimation {
                                    algorithm = algo
                                    autoAlgo = false
                                }

                            } label: {
                                if algo.isInsecure {
                                    Text(
                                        "\(Image(systemName: "exclamationmark.triangle")) \(algo.displayName)"
                                    )
                                } else {
                                    Text(algo.displayName)
                                }
                            }
                        }
                    } label: {
                        Text(algorithm.displayName)
                            .font(.body.weight(.medium))
                            .foregroundStyle(theme.color.textPrimary)
                    }
                    .tint(theme.color.primary)

                    if autoAlgo {
                        Text("(auto)")
                            .font(Font.callout.monospacedDigit())
                    }
                }

            }

            //Spacer(minLength: 0)
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
            withAnimation {
                digestHovered = hovering
            }
        }
        .animation(.default, value: file.request.mode)
        .task(id: run) {
            guard run else { return }
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
                elapsed = clock.now - start
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
