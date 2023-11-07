import SwiftUI

@main
struct TCACoordinatorExampleApp: App {
  var body: some Scene {
    WindowGroup {
      MainTabCoordinatorView(store: .init(initialState: .initialState) {
        MainTabCoordinator()
      })
    }
  }
}
