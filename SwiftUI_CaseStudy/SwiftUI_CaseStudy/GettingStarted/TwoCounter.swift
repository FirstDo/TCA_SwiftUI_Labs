import SwiftUI
import ComposableArchitecture

struct TwoCounter: ReducerProtocol {
    struct State: Equatable {
        var counter1 = Counter.State()
        var counter2 = Counter.State()
    }
    
    enum Action {
        case counter1(Counter.Action)
        case counter2(Counter.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.counter1, action: /Action.counter1) {
            Counter()
        }
        Scope(state: \.counter2, action: /Action.counter2) {
            Counter()
        }
    }
}

struct TwoCounterView: View {
    let store: StoreOf<TwoCounter>
    
    var body: some View {
        Form {
            HStack {
                Text("Counter1")
                Spacer()
                CounterView(store: store.scope(state: \.counter1, action: TwoCounter.Action.counter1))
            }
            
            HStack {
                Text("Counter2")
                Spacer()
                CounterView(store: store.scope(state: \.counter2, action: TwoCounter.Action.counter2))
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle("Two Counters")
    }
}

struct TwoCounterView_Previews: PreviewProvider {
    static var previews: some View {
        TwoCounterView(store: Store(initialState: TwoCounter.State(), reducer: TwoCounter()))
    }
}
