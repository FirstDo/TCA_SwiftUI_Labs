import SwiftUI
import ComposableArchitecture

struct AddContactView: View {
    let store: StoreOf<AddContactFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                TextField("Name", text: viewStore.binding(get: \.contact.name, send: { .setName($0)}))
                Button("Save") {
                    viewStore.send(.saveButtonTapped(viewStore.contact))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel", role: .cancel) {
                        viewStore.send(.cancelButtonTapped)
                    }
                }
            }
        }
    }
}

struct AddContactView_Previews: PreviewProvider {
    static var previews: some View {
        AddContactView(
            store: .init(initialState: AddContactFeature.State(contact: .init(id: UUID(), name: ""))) {
                AddContactFeature()
            }
        )
    }
}
