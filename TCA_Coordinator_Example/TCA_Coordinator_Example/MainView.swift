import SwiftUI
import ComposableArchitecture

struct MainFeature: Reducer {
    struct State: Equatable {
        var count = 0
    }
    
    enum Action: Equatable {
        case buttonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .buttonTapped:
                return .none
            }
        }
    }
}

struct MainView: View {
    let store: StoreOf<MainFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text("\(viewStore.count)")
                Button("Next") {
                    store.send(.buttonTapped)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
