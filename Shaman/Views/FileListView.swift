//
//  FileList.swift
//  Shaman
//
//  Created by winston on 8/19/26.
//

import SwiftUI

struct FileListView: View {

    @Binding var files: [DroppedFile]
    @Binding var hashRequest: HashRequest

    var body: some View {
        if files.isEmpty {
            VStack {
                Text("Drop files here")
                    .font(.headline)
            }
        } else {
            ScrollView {
                ForEach(files) { file in
                    FileBubble(file: file, hashRequest: $hashRequest)
                }

            }
            .padding(5)
        }
    }

}
