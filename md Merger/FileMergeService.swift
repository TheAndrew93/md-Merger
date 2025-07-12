import SwiftUI
import UniformTypeIdentifiers

final class FileMergeService: ObservableObject {
    @Published var isMerging = false
    @Published var statusText = ""
    private let alertManager: AlertManager

    init(alertManager: AlertManager) {
        self.alertManager = alertManager
    }

    /// Merge the given Markdown file URLs, inserting `---` between each.
    func mergeFiles(_ fileURLs: [URL], completion: @escaping (URL?) -> Void) {
        guard !fileURLs.isEmpty else {
            alertManager.presentError(
                title: "No Files Selected",
                message: "Please select at least one Markdown file to merge."
            )
            completion(nil)
            return
        }

        isMerging = true
        statusText = "Reading files…"

        DispatchQueue.global(qos: .userInitiated).async {
            var combinedText = ""
            for (index, fileURL) in fileURLs.enumerated() {
                do {
                    let content = try String(contentsOf: fileURL, encoding: .utf8)
                    combinedText += content
                    if index < fileURLs.count - 1 {
                        combinedText += "\n\n---\n\n"
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isMerging = false
                        self.alertManager.presentError(
                            title: "File Read Error",
                            message: "Could not read file: \(fileURL.lastPathComponent)\n\n\(error.localizedDescription)"
                        )
                        completion(nil)
                    }
                    return
                }
            }

            DispatchQueue.main.async {
                self.statusText = "Choosing destination…"
                self.presentSavePanel(for: combinedText, completion: completion)
            }
        }
    }

    /// Show an NSSavePanel to let the user pick a filename/folder.
    private func presentSavePanel(for combinedText: String, completion: @escaping (URL?) -> Void) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.plainText]
        savePanel.nameFieldStringValue = defaultMergedFileName()
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false

        savePanel.begin { [weak self] response in
            guard let self = self else { return }
            if response == .OK, let destinationURL = savePanel.url {
                self.writeCombinedText(combinedText, to: destinationURL, completion: completion)
            } else {
                // User canceled
                self.isMerging = false
                self.statusText = "Merge canceled"
                completion(nil)
            }
        }
    }

    /// Write the merged text to disk, prompting to overwrite if needed.
    private func writeCombinedText(_ text: String, to url: URL, completion: @escaping (URL?) -> Void) {
        if FileManager.default.fileExists(atPath: url.path) {
            alertManager.presentOverwriteConfirmation {
                do {
                    try text.write(to: url, atomically: true, encoding: .utf8)
                    DispatchQueue.main.async {
                        self.finishMerge(successURL: url, completion: completion)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isMerging = false
                        self.alertManager.presentError(
                            title: "Write Error",
                            message: "Could not write merged file:\n\n\(error.localizedDescription)"
                        )
                        completion(nil)
                    }
                }
            }
        } else {
            do {
                try text.write(to: url, atomically: true, encoding: .utf8)
                finishMerge(successURL: url, completion: completion)
            } catch {
                isMerging = false
                alertManager.presentError(
                    title: "Write Error",
                    message: "Could not write merged file:\n\n\(error.localizedDescription)"
                )
                completion(nil)
            }
        }
    }

    /// Conclude the merge: update status, show file in Finder, call completion.
    private func finishMerge(successURL: URL, completion: @escaping (URL?) -> Void) {
        isMerging = false
        statusText = "Merge successful: \(successURL.lastPathComponent)"
        completion(successURL)
        NSWorkspace.shared.activateFileViewerSelecting([successURL])
    }

    /// Default merged filename in “Merged_YYYYMMDD_HHMMSS.md” format.
    private func defaultMergedFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = formatter.string(from: Date())
        return "Merged_\(timestamp).md"
    }
}
