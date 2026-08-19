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
    @State private var run: Bool = false

    @Binding var files: [DroppedFile]

    var body: some View {

        ZStack {

            FileListView(files: $files, run: $run)
                .padding(run ? 5 : 16)

            if !files.isEmpty && !run {
                VStack {
                    Spacer()
                    Button(
                        action: {
                            withAnimation {
                                run = true
                            }
                        },
                        label: {
                            Text("Hash")
                                .font(.body.weight(.medium))
                                .foregroundStyle(theme.color.textPrimary)
                        }
                    )
                    .padding(20)
                    .buttonStyle(.glass)
                    .tint(theme.color.bgSurface)

                }
            }

            if !run {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .foregroundStyle(
                        isTargeted ? theme.color.primary : theme.color.border
                    )
                    .padding(5)
            }

        }
        .dropDestination(for: URL.self) { urls, _ in
            if !run {
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
