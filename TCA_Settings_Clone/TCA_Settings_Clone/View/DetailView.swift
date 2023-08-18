import SwiftUI
import ComposableArchitecture

struct DetailFeature: Reducer {
    struct State: Equatable {
        let title: String
    }
    
    enum Action: Equatable {
        case backButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .backButtonTapped:
            return .run { _ in
                await dismiss()
            }
        }
    }
}

struct DetailView: View {
    let store: StoreOf<DetailFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text(viewStore.title)
                Button("뒤로가기") {
                    store.send(.backButtonTapped)
                }
                .buttonStyle(.borderedProminent)
            }
            .font(.largeTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(store: .init(initialState: .init(title: "Wi-Fi")) { DetailFeature() })
    }
}
