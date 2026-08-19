//
//  HashDigest.swift
//  Shaman
//
//  Created by winston on 8/19/26.
//
import SwiftUI
import CryptoKit

nonisolated struct HashDigest {
    let algorithm: HashAlgorithm
    let bytes: [UInt8]

    var hex: String {
        bytes.map { String(format: "%02x", $0) }.joined()
    }

    init(algorithm: HashAlgorithm, digest: some Digest) {
        self.algorithm = algorithm
        self.bytes = Array(digest)
    }
}
