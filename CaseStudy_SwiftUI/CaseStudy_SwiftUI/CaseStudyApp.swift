import SwiftUI
import ComposableArchitecture

@main
struct CaseStudyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(store: Store(initialState: Root.State()) { Root() } )
        }
    }
}
