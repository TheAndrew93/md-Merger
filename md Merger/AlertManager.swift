import SwiftUI
import Combine

final class AlertManager: ObservableObject {
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var alertButtons: [Alert.Button] = []

    func presentError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        alertButtons = [.default(Text("OK"))]
        showAlert = true
    }

    func presentOverwriteConfirmation(overwriteHandler: @escaping () -> Void) {
        alertTitle = "File Already Exists"
        alertMessage = "A file with this name already exists. Do you want to overwrite it?"
        alertButtons = [
            .destructive(Text("Overwrite"), action: overwriteHandler),
            .cancel()
        ]
        showAlert = true
    }
}
