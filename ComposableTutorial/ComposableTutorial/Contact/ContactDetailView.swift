import SwiftUI
import ComposableArchitecture

struct ContactDetailView: View {
    let store: StoreOf<ContactDetailFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Button("Delete") {
                    viewStore.send(.deleteButtonTapped)
                }
            }
            .navigationTitle(Text(viewStore.contact.name))
        }
        .alert(store: store.scope(state: \.$alert, action: { .alert($0)}))
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContactDetailView(
                store: .init(
                    initialState: ContactDetailFeature.State(contact: Contact(id: UUID(), name: "dudu")),
                    reducer: { ContactDetailFeature() }
                )
            )
        }
    }
}
