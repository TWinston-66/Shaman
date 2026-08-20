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

                HeaderView()

                DropZoneView(files: $files)
            }
            .frame(minWidth: 880, minHeight: 430)
            .environment(\.theme, .default)

        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
