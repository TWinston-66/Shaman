//
//  LoadView 2.swift
//  Shaman
//
//  Created by winston on 8/18/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @Environment(\.theme) private var theme

    @State private var isTargeted = false
    @State private var globalMode = ModeState(run: false, mode: .generate, hasEmptyCheck: false, algorithm: .default)
   
    @Binding var files: [DroppedFile]

    private var hashLabel: String {
        return "Hash (\(files.count))"
    }
    
    private var hashButtonDisabled: Bool {
        switch globalMode.mode {
        case .check:
            return globalMode.hasEmptyCheck
        case .generate:
            return false
        }
    }
    

    var body: some View {

        ZStack {

            FileListView(files: $files, globalMode: $globalMode)
                .padding(globalMode.run ? 5 : 16)

            if !files.isEmpty && !globalMode.run {
                VStack {
                    Spacer()

                    HStack(spacing: 5) {
                        Button(
                            action: {
                                withAnimation {
                                    globalMode.run = true
                                }
                            },
                            label: {
                                Text(hashLabel)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(theme.color.textPrimary)
                            }
                        )
                        .buttonStyle(.glass)
                        .tint(theme.color.bgSurface)
                        .disabled(hashButtonDisabled)

                        Menu {
                            ForEach(HashAlgorithm.allCases) { algo in
                                Button {
                                    globalMode.algorithm = algo
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
                            Text(globalMode.algorithm.displayName)
                                .font(.body.weight(.medium))
                                .foregroundStyle(theme.color.textPrimary)
                        }
                        .tint(theme.color.primary)
                    }
                    .padding(20)

                }
            }

            if !globalMode.run {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .foregroundStyle(
                        isTargeted ? theme.color.primary : theme.color.border
                    )
                    .padding(5)
            }

        }
        .dropDestination(for: URL.self) { urls, _ in
            if !globalMode.run {
                let fileURLs = urls.filter(\.isFileURL)
                guard !fileURLs.isEmpty else { return false }
                var accepted = false
                for url in fileURLs {
                    if updateFiles(url) {
                        accepted = true
                    }
                }
                return accepted
            }
            return false

        } isTargeted: {
            isTargeted = $0
        }

    }

    private func updateFiles(_ url: URL) -> Bool {
        let file = open(url)
        guard let f = file else { return false }
        if !files.contains(where: { $0.path == f.path }) {
            files.append(f)
        }
        return true
    }

    private func open(_ url: URL) -> DroppedFile? {

        let rv = try? url.resourceValues(forKeys: [
            .contentTypeKey, .fileSizeKey, .nameKey,
        ])

        return DroppedFile(
            name: rv?.name ?? url.lastPathComponent,
            path: url,
            type: rv?.contentType,
            size: Int64(rv?.fileSize ?? 0)
        )

    }
}
