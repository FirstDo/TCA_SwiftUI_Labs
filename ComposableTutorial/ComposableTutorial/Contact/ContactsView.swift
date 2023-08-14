import SwiftUI
import ComposableArchitecture

struct ContactsView: View {
    let store: StoreOf<ContactsFeature>
    var body: some View {
        NavigationStack {
            WithViewStore(store, observe: \.contacts) { viewStore in
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
                .animation(.default, value: viewStore.state)
                .navigationTitle("Contacts")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewStore.send(.addButtonTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                        
                    }
                }
            }
            .sheet(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /ContactsFeature.Destination.State.addContact,
                action: ContactsFeature.Destination.Action.addContact) { subStore in
                    NavigationStack {
                        AddContactView(store: subStore)
                    }
                }
            .alert(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /ContactsFeature.Destination.State.alert,
                action: ContactsFeature.Destination.Action.alert
            )
        }
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView(
            store: Store(initialState: ContactsFeature.State(contacts: Contact.dummy)) {
                ContactsFeature()
            }
        )
    }
}
