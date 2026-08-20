//
//  FileList.swift
//  Shaman
//
//  Created by winston on 8/19/26.
//

import SwiftUI

struct FileListView: View {

    @Binding var files: [DroppedFile]
    @Binding var run: Bool
    @Binding var jobCancel: Bool

    var body: some View {
        if files.isEmpty {
            VStack {
                Text("Drop files here")
                    .font(.headline)
            }
        } else {
            ScrollView {
                ForEach($files) { $file in
                    let id = file.id
                    FileBubble(file: $file, run: $run, jobCancel: $jobCancel) {
                        withAnimation { files.removeAll { $0.id == id } }
                    }
                }

            }
            .padding(5)
        }
    }

}
