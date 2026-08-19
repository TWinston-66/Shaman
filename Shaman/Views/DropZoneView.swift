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
    @State private var run = false

    @Binding var files: [DroppedFile]

    private var hashLabel: String {
        return "Hash (\(files.count))"
    }
    
    private var hashButtonDisabled: Bool {
        files.contains { $0.request.isBlankCheck }
    }

    private var allFilesDone: Bool {
        !files.isEmpty && files.allSatisfy(\.done)
    }
    

    var body: some View {

        ZStack {

            FileListView(files: $files, run: $run)
                .padding(run ? 5 : 16)

            if !files.isEmpty && (!run || allFilesDone) {
                VStack {
                    Spacer()

                    if allFilesDone {
                        Button(action: {
                            withAnimation {
                                run = false
                                files = []
                            }
                        }, label: {
                            Text("Start Over")
                                .font(.body.weight(.medium))
                                .foregroundStyle(theme.color.textPrimary)
                        })
                        .buttonStyle(.glass)
                        .tint(theme.color.bgSurface)
                        .padding(20)
                    }

                    if !run {
                        HStack(spacing: 5) {

                            Button(
                                action: {
                                    withAnimation {
                                        run = true
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

                            
                        }
                        .padding(20)
                    }

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
            size: Int64(rv?.fileSize ?? 0),
            done: false
        )

    }
}
