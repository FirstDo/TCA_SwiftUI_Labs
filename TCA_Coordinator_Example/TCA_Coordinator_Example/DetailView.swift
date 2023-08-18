import SwiftUI
import ComposableArchitecture

struct DetailFeature: Reducer {
    struct State: Equatable { }
    
    enum Action: Equatable {
        case backButtonTapped
        case increaseNumber
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .backButtonTapped:
            return .none
            
        case .increaseNumber:
            return .none
        }
    }
}

struct DetailView: View {
    let store: StoreOf<DetailFeature>
    
    var body: some View {
        VStack {
            Button("back") {
                store.send(.backButtonTapped)
            }
            Button("increase") {
                store.send(.increaseNumber)
            }
        }
        .buttonStyle(.borderedProminent)
    }
}
