//
//  Shaman.swift
//  Shaman
//
//  Created by winston on 8/18/26.
//

import SwiftUI
import UniformTypeIdentifiers

extension EnvironmentValues {
    @Entry var theme: Theme = .default
}

@main struct ShamanApp: App {

    @State private var files: [DroppedFile] = []

    var body: some Scene {
        WindowGroup {

            VStack(alignment: .leading, spacing: 0) {

                HeaderView(version: "v0.1.0")

                DropZoneView(files: $files)
                    .frame(minWidth: 500, maxWidth: .infinity)
                    .frame(height: 400)

            }
            .environment(\.theme, .default)

        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
