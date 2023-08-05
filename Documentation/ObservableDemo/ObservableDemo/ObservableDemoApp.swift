import SwiftUI

@main
struct ObservableDemoApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
                // Use the on-disk repository in the application
                .environment(\.playerRepository, .shared)
        }
    }
}
