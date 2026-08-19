//
//  BubbleForm.swift
//  Shaman
//
//  Created by winston on 8/19/26.
//

import SwiftUI

struct BubbleForm: View {
    @Environment(\.theme) private var theme
    
    @Binding var file: DroppedFile
    @Binding var algorithm: HashAlgorithm
    @Binding var run: Bool
    @Binding var autoAlgo: Bool
    
    var body: some View {
        VStack(spacing: 5) {

            Picker("", selection: $file.request.mode) {
                ForEach(Mode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                        .font(.caption)
                }
            }
            .pickerStyle(.segmented)
            .tint(theme.color.textMuted)
            .scaleEffect(0.8)
            .disabled(run)

            HStack(spacing: 5) {
                Menu {
                    ForEach(HashAlgorithm.allCases) { algo in
                        Button {
                            withAnimation {
                                algorithm = algo
                                autoAlgo = false
                            }

                        } label: {
                            if algo.isInsecure {
                                Text(
                                    "\(Image(systemName: "exclamationmark.triangle")) \(algo.displayName)"
                                )
                            } else {
                                Text(algo.displayName)
                            }
                        }
                    }
                } label: {
                    Text(algorithm.displayName)
                        .font(.body.weight(.medium))
                        .foregroundStyle(theme.color.textPrimary)
                }
                .tint(theme.color.primary)

                if autoAlgo {
                    Text("(auto)")
                        .font(Font.callout.monospacedDigit())
                }
            }

        }
    }
}

