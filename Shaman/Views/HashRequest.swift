//
//  HashRequest.swift
//  Shaman
//
//  Created by winston on 8/19/26.
//

enum Mode: String, CaseIterable {
    case check = "Check"
    case generate = "Generate"
}

struct HashRequest: Equatable {
    var compareHex: String
    var mode: Mode
}

struct ModeState: Equatable {
    var run: Bool
    var mode: Mode
    var hasEmptyCheck: Bool
    var algorithm: HashAlgorithm
}
