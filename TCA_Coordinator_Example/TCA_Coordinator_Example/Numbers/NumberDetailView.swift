import SwiftUI
import ComposableArchitecture

struct NumberDetail: Reducer {
    struct State: Equatable {
        let id = UUID()
        var number: Int
    }
    
    enum Action {
        case goBackTapped
        case goBackToRootTapped
        case goBackToNumbersList
        case incrementAfterDelayTapped
        case incrementTapped
        case showDouble(Int)
    }
    
    @Dependency(\.mainQueue) var mainQueue
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .goBackToRootTapped, .goBackTapped, .goBackToNumbersList, .showDouble:
                return .none
                
            case .incrementAfterDelayTapped:
                return .run { send in
                    try await mainQueue.sleep(for: .seconds(3))
                    await send(.incrementTapped)
                }
                
            case .incrementTapped:
                state.number += 1
                return .none
            }
        }
    }
}

struct NumberDetailView: View {
    let store: StoreOf<NumberDetail>
    
    var body: some View {
        WithViewStore(store, observe: \.number) { viewStore in
            VStack(spacing: 8) {
                Text("Number \(viewStore.state)")
                Button("Increment") {
                    viewStore.send(.incrementTapped)
                }
                Button("Increment after delay") {
                    viewStore.send(.incrementAfterDelayTapped)
                }
                Button("Show double") {
                    viewStore.send(.showDouble(viewStore.state))
                }
                Button("Go back") {
                    viewStore.send(.goBackTapped)
                }
                Button("Go back to root") {
                    viewStore.send(.goBackToRootTapped)
                }
                Button("Go back to numbers list") {
                    viewStore.send(.goBackToNumbersList)
                }
            }
            .navigationTitle("Number \(viewStore.state)")
        }
    }
}
