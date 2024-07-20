import SwiftUI

@main
struct MVVMDemoApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
                // Use the on-disk repository in the application
                .playerRepository(.shared)
        }
    }
}
