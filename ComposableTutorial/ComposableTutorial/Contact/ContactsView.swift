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
                        HStack {
                            Text(contact.name)
                            Spacer()
                            Button {
                                viewStore.send(.deleteButtonTapped(id: contact.id))
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }

                        }
                        
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
                state: \.$destionation,
                action: { .destination($0) }
            ),
            state: /ContactsFeature.Destination.State.addContact,
            action: ContactsFeature.Destination.Action.addContact
        ) { contactStore in
            NavigationStack {
                AddContactView(store: contactStore)
            }
        }
        .alert(
            store: self.store.scope(state: \.$destionation, action: { .destination($0) }),
            state: /ContactsFeature.Destination.State.alert,
            action: ContactsFeature.Destination.Action.alert
        )
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
