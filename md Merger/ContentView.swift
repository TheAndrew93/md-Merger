import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject private var mergeService: FileMergeService

    @State private var fileURLs: [URL] = []

    var body: some View {
        VStack(spacing: 12) {
            // Title
            Text("Markdown Merger")
                .font(.largeTitle)
                .padding(.top, 20)

            Text("Drag & drop or select multiple .md files to merge")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // File List (with implicit drag-to-reorder on macOS)
            if fileURLs.isEmpty {
                Spacer()
                Text("No files selected")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(fileURLs, id: \.self) { url in
                        Text(url.lastPathComponent)
                    }
                    .onMove(perform: moveItem)
                }
                .frame(maxHeight: 200)
            }

            // Buttons
            HStack(spacing: 20) {
                Button(action: presentFilePicker) {
                    Text("Select Files…")
                }
                .disabled(mergeService.isMerging)

                if fileURLs.count > 1 {
                    Button(action: mergeSelectedFiles) {
                        Text("Merge")
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(mergeService.isMerging)
                }
            }

            // Progress & Status
            if mergeService.isMerging {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 10)
                Text(mergeService.statusText)
                    .font(.caption)
                    .foregroundColor(.blue)
            } else if !mergeService.statusText.isEmpty {
                Text(mergeService.statusText)
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.top, 10)
            }
        }
        .padding(20)
        // MARK: Drag-and-Drop Support
        .onDrop(of: [UTType.fileURL], isTargeted: nil, perform: handleDrop(providers:))
        // MARK: Alert Binding
        .alert(isPresented: $alertManager.showAlert) {
            if alertManager.alertButtons.count == 1 {
                return Alert(
                    title: Text(alertManager.alertTitle),
                    message: Text(alertManager.alertMessage),
                    dismissButton: alertManager.alertButtons.first
                )
            } else {
                return Alert(
                    title: Text(alertManager.alertTitle),
                    message: Text(alertManager.alertMessage),
                    primaryButton: alertManager.alertButtons[0],
                    secondaryButton: alertManager.alertButtons[1]
                )
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }

    // MARK: File Picker
    private func presentFilePicker() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.plainText]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        panel.begin { response in
            if response == .OK {
                let mdURLs = panel.urls.filter { $0.pathExtension.lowercased() == "md" }
                if mdURLs.isEmpty {
                    alertManager.presentError(
                        title: "Invalid Selection",
                        message: "No Markdown files (.md) were selected."
                    )
                } else {
                    fileURLs.append(contentsOf: mdURLs)
                }
            }
        }
    }

    // MARK: Drag-and-Drop
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var found = false
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil),
                       url.pathExtension.lowercased() == "md" {
                        DispatchQueue.main.async {
                            self.fileURLs.append(url)
                        }
                        found = true
                    }
                }
            }
        }
        return found
    }

    // MARK: Reordering
    private func moveItem(from source: IndexSet, to destination: Int) {
        fileURLs.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: Merge
    private func mergeSelectedFiles() {
        mergeService.mergeFiles(fileURLs) { mergedURL in
            // Optionally clear fileURLs here if desired
        }
    }
}
