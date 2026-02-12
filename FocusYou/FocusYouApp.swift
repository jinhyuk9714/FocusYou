import SwiftUI
import SwiftData

@main
struct FocusYouApp: App {
    var body: some Scene {
        MenuBarExtra {
            Text("Focus You v0.1")
                .padding()
        } label: {
            Image(systemName: "shield.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
