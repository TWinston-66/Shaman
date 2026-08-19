//
//  LoadView 2.swift
//  Shaman
//
//  Created by winston on 8/18/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.theme) private var theme
    
    @State private var isTargeted = false
    @State private var run: Bool = false

    @Binding var files: [DroppedFile]

    var body: some View {

        ZStack {

            FileList(files: $files, run: $run)
                .padding(run ? 5 : 16)

            if !files.isEmpty {
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
                    .foregroundStyle(isTargeted ? theme.color.primary : theme.color.border)
                    .padding(5)
            }
            

        }
        .dropDestination(for: URL.self) { urls, _ in
            if !run {
                guard urls.count == 1, let url = urls.first, url.isFileURL
                else {
                    return false
                }
                return updateFiles(url)
            }
            return false
            
        } isTargeted: {
            isTargeted = $0
        }

    }

    private func updateFiles(_ url: URL) -> Bool {
        let file = open(url)
        guard let f = file else { return false }
        files.append(f)
        return true
    }

    private func open(_ url: URL) -> DroppedFile? {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }

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

struct FileList: View {
    
    @Binding var files: [DroppedFile]
    @Binding var run: Bool
    
    var body: some View {
        if files.isEmpty {
            VStack {
                Text("Drop files here")
                    .font(.headline)
            }
        } else {
            ScrollView {
                ForEach(files) { file in
                    FileBubble(file: file, run: $run)
                }

            }
            .padding(5)
        }
    }

}
