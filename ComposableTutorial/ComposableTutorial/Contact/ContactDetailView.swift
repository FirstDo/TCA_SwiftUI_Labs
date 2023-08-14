import SwiftUI
import ComposableArchitecture

struct ContactDetailView: View {
    let store: StoreOf<ContactDetailFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                
            }
            .navigationTitle(Text(viewStore.contact.name))
        }
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
