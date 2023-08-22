import SwiftUI
import ComposableArchitecture

struct Home: Reducer {
    struct State: Equatable {
        let id = UUID()
    }
    
    enum Action {
        case startTapped
    }
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

struct HomeView: View {
    let store: StoreOf<Home>
    
    var body: some View {
        VStack {
            Button("Start") {
                store.send(.startTapped)
            }
        }
        .navigationTitle("Home")
    }
}
