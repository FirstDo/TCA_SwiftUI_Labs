import SwiftUI
import ComposableArchitecture

@main
struct MyApp: App {
    static let store = Store(initialState: ContactsFeature.State(contacts: Contact.dummy)) {
        ContactsFeature()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            ContactsView(store: MyApp.store)
        }
    }
}
