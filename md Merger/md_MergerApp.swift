//
//  md_MergerApp.swift
//  md Merger
//
//  Created by Andrew Rosado on 2025-06-05.
//

import SwiftUI

@main
struct md_MergerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: md_MergerDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
