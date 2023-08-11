import SwiftUI
import ComposableArchitecture

struct AddContactView: View {
    let store: StoreOf<AddContactFeature>
    @ObservedObject var viewStore: ViewStoreOf<AddContactFeature>
    
    init(store: StoreOf<AddContactFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        Form {
            TextField("Name", text: viewStore.binding(
                get: \.contact.name,
                send: { .setName($0)}
            ))
            Button("Save") {
                viewStore.send(.saveButtonTapped)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Cancel") {
                    viewStore.send(.cancelButtonTapped)
                }
            }
        }
    }
}

struct AddContactView_Previews: PreviewProvider {
    static var previews: some View {
        AddContactView(
            store: .init(initialState: AddContactFeature.State(contact: Contact(id: UUID(), name: "dudu"))) {
                AddContactFeature()
            }
        )
    }
}
