import SwiftUI
import ComposableArchitecture

struct ContactsView: View {
    let store: StoreOf<ContactsFeature>
    //    @ObservedObject var viewStore: ViewStoreOf<ContactsFeature>
    
    init(store: StoreOf<ContactsFeature>) {
        self.store = store
        //        self.viewStore = ViewStore(store, observe: {$0})
    }
    var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: \.contacts) { viewStore in
                List {
                    ForEach(viewStore.state) { contact in
                        Text(contact.name)
                    }
                }
                .navigationTitle("Contacts")
                .toolbar {
                    ToolbarItem {
                        Button {
                            viewStore.send(.addButtonTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .sheet(
            store: self.store.scope(
                state: \.$addContact,
                action: { .addContact($0) }
            )
        ) { contactStore in
            NavigationStack {
                AddContactView(store: contactStore)
            }
        }
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView(
            store: .init(initialState: .init()) {
                ContactsFeature()
            }
        )
    }
}
