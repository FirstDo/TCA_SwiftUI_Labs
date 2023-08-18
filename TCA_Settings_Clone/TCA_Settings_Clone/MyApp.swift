import SwiftUI
import ComposableArchitecture

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            SettingsView(store: .init(initialState: .init()) {
                SettingsFeature()
                    ._printChanges()
            })
        }
    }
}
