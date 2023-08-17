import SwiftUI
import ComposableArchitecture

struct ContactsView: View {
    let store: StoreOf<ContactsFeature>
    var body: some View {
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
                    .onTapGesture {
                        viewStore.send(.itemTapped(contact: contact))
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
