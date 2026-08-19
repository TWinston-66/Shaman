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
    @State private var hashRequest = HashRequest(
        run: false,
        algorithm: .default
    )

    @Binding var files: [DroppedFile]

    private var hashLabel: String {
        return "Hash (\(files.count))"
    }

    var body: some View {

        ZStack {

            FileListView(files: $files, hashRequest: $hashRequest)
                .padding(hashRequest.run ? 5 : 16)

            if !files.isEmpty && !hashRequest.run {
                VStack {
                    Spacer()

                    HStack(spacing: 5) {
                        Button(
                            action: {
                                withAnimation {
                                    hashRequest.run = true
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

                        Menu {
                            ForEach(HashAlgorithm.allCases) { algo in
                                Button {
                                    hashRequest.algorithm = algo
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
                            Text(hashRequest.algorithm.displayName)
                                .font(.body.weight(.medium))
                                .foregroundStyle(theme.color.textPrimary)
                        }
                        .tint(theme.color.primary)
                    }
                    .padding(20)

                }
            }

            if !hashRequest.run {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .foregroundStyle(
                        isTargeted ? theme.color.primary : theme.color.border
                    )
                    .padding(5)
            }

        }
        .dropDestination(for: URL.self) { urls, _ in
            if !hashRequest.run {
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
