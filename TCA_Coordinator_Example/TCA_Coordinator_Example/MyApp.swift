import SwiftUI
import ComposableArchitecture
import TCACoordinators

@main
struct TCA_Coordinator_ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            FormAppCoordinatorView(store: .init(initialState: .initalState) {
                FormAppCoordinator()
            })
        }
    }
}
