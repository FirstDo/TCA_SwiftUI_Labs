import SwiftUI
import ComposableArchitecture
import TCACoordinators

@main
struct TCA_Coordinator_ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabCoordinatorView(store: .init(initialState: .initState) {
                MainTabCoordinator()
            })
        }
    }
}
