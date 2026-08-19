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

            DropZoneView(files: $files)
                .frame(minWidth: 500)
                .fixedSize(horizontal: true, vertical: false)
                .frame(height: 400)
                .environment(\.theme, .default)

        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
