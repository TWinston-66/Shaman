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

@main struct Shaman: App {

    @State private var files: [DroppedFile] = []

    var body: some Scene {
        WindowGroup {

            ContentView(files: $files)
                .frame(width: 500, height: 400)
                .environment(\.theme, .default)

        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
