import SwiftUI
import ComposableArchitecture

struct SearchBarFeature: Reducer {
    struct State: Equatable {
        var title: String = ""
    }
    
    enum Action: Equatable {
        case setTilte(String)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .setTilte(text):
            state.title = text
            return .none
        }
    }
}

struct SearchBar: View {
    let store: StoreOf<SearchBarFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("??", text: viewStore.binding(get: \.title, send: { .setTilte($0)}))
            }
            .padding(2)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.2)))
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(store: .init(initialState: .init()) {
            SearchBarFeature()
                ._printChanges()
        })
        .previewLayout(.sizeThatFits)
    }
}
