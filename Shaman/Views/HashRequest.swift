//
//  HashRequest.swift
//  Shaman
//
//  Created by winston on 8/19/26.
//

import Foundation

enum Mode: String, CaseIterable {
    case check = "Check"
    case generate = "Generate"
}

struct HashRequest: Equatable {
    var compareHex: String
    var mode: Mode

    var isBlankCheck: Bool {
        mode == .check && compareHex.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct ModeState: Equatable {
    var run: Bool
    var algorithm: HashAlgorithm
}
