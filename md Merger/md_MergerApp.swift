import SwiftUI

@main
struct md_MergerApp: App {
    // Create shared services as StateObjects so they live for the life of the app
    @StateObject private var alertManager = AlertManager()
    @StateObject private var mergeService = FileMergeService(alertManager: AlertManager())

    var body: some Scene {
        WindowGroup {
            // Inject both services into the environment
            ContentView()
                .environmentObject(alertManager)
                .environmentObject(mergeService)
        }
    }
}
