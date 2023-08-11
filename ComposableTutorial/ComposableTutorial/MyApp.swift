import SwiftUI
import ComposableArchitecture

@main
struct MyApp: App {
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
            ._printChanges()
    }
    static let store2 = Store(initialState: ContactsFeature.State()) {
        ContactsFeature()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            ContactsView(store: MyApp.store2)
//            CounterView(store: MyApp.store)
        }
    }
}
