//
//  DroppedFile.swift
//  Shaman
//
//  Created by winston on 8/18/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct DroppedFile: Identifiable {
    let id = UUID()
    let name: String
    let path: URL
    let type: UTType?
    let size: Int64
    var done: Bool

    var directory: String {
        let path = path.deletingLastPathComponent().path(percentEncoded: false)
        let home = FileManager.default.homeDirectoryForCurrentUser.path(
            percentEncoded: false
        )
        if path == home { return "~" }
        if path.hasPrefix(home + "/") {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }

    var subtitle: String {
        [
            type?.localizedDescription,
            size.formatted(.byteCount(style: .file)),
            directory,
        ]
        .compactMap { $0 }
        .joined(separator: " · ")
    }
}
