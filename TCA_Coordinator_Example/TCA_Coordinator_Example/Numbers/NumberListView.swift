import SwiftUI
import ComposableArchitecture

struct NumberList: Reducer {
    struct State: Equatable {
        let id = UUID()
        let numbers: [Int]
    }
    
    enum Action {
        case numberSelected(Int)
    }
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

struct NumberListView: View {
    let store: StoreOf<NumberList>
    
    var body: some View {
        WithViewStore(store, observe: \.numbers) { viewStore in
            List(viewStore.state, id: \.self) { number in
                Button("\(number)") {
                    viewStore.send(.numberSelected(number))
                }
            }
        }
        .navigationTitle("Numbers")
    }
}
