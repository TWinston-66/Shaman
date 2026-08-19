//
//  FileHasher.swift
//  Shaman
//
//  Created by winston on 8/18/26.
//

import CryptoKit
import SwiftUI

struct FileHasher {

    let file: DroppedFile
    let algorithm: HashAlgorithm
    private nonisolated static let chunkSize = 1 << 20

    @concurrent nonisolated func hash(
        onProgress: @MainActor (Double) -> Void = { _ in }
    ) async throws -> HashDigest {
        let total = Int(file.size)
        let handle = try FileHandle(forReadingFrom: file.path)
        defer { try? handle.close() }

        var hasher = await algorithm.makeHasher()
        var bytesRead = 0
        var lastStep = -1

        while let chunk = try handle.read(upToCount: Self.chunkSize), !chunk.isEmpty
        {
            try Task.checkCancellation()
            hasher.update(data: chunk)
            bytesRead += chunk.count

            guard total > 0 else { continue }
            let step = bytesRead * 100 / total
            if step != lastStep {
                lastStep = step
                await onProgress(Double(step) / 100)
            }
        }
        await onProgress(1.0)
        
        return HashDigest(algorithm: algorithm, digest: hasher.finalize())
    }
}
