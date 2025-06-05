//
//  ContentView.swift
//  md Merger
//
//  Created by Andrew Rosado on 2025-06-05.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: md_MergerDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(md_MergerDocument()))
}
