import SwiftUI
import ComposableArchitecture
import TCACoordinators

@main
struct TCA_Coordinator_ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            CoordinatorView(
                store: .init(initialState: .init()) {
                    Coordinator()
                })
        }
    }
}
