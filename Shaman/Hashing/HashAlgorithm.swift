//
//  HashAlgorithm.swift
//  Shaman
//
//  Created by winston on 8/19/26.
//

import SwiftUI
import CryptoKit

enum HashAlgorithm: CaseIterable, Identifiable, Sendable {
    case md5
    case sha1
    case sha256
    case sha384
    case sha512

    static let `default`: HashAlgorithm = .sha256

    var id: Self { self }

    var displayName: String {
        switch self {
        case .md5: "MD5"
        case .sha1: "SHA-1"
        case .sha256: "SHA-256"
        case .sha384: "SHA-384"
        case .sha512: "SHA-512"
        }
    }

    var isInsecure: Bool {
        switch self {
        case .md5, .sha1: true
        case .sha256, .sha384, .sha512: false
        }
    }

    var byteCount: Int {
        switch self {
        case .md5: Insecure.MD5.Digest.byteCount
        case .sha1: Insecure.SHA1.Digest.byteCount
        case .sha256: SHA256.Digest.byteCount
        case .sha384: SHA384.Digest.byteCount
        case .sha512: SHA512.Digest.byteCount
        }
    }

    func makeHasher() -> any HashFunction { function.init() }

    private var function: any HashFunction.Type {
        switch self {
        case .md5: Insecure.MD5.self
        case .sha1: Insecure.SHA1.self
        case .sha256: SHA256.self
        case .sha384: SHA384.self
        case .sha512: SHA512.self
        }
    }
}
extension HashAlgorithm {
    init?(hexDigestLength: Int) {
        guard let match = Self.allCases.first(where: {
            $0.byteCount * 2 == hexDigestLength
        }) else { return nil }
        self = match
    }
}
