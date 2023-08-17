import SwiftUI
import ComposableArchitecture

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            CoordinatorView(store: .init(initialState: .init()) {
                Coordinator()
            })
        }
    }
}
