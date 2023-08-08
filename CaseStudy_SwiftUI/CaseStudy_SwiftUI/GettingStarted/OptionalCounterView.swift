import SwiftUI
import ComposableArchitecture

struct OptionalCounter: Reducer {
    struct State: Equatable {
        var optionalCounter: Counter.State?
    }
    
    enum Action {
        case optionalCounter(Counter.Action)
        case toggleCounterButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
            case .toggleCounterButtonTapped:
                state.optionalCounter = state.optionalCounter == nil
                ? Counter.State()
                : nil
                return .none
            case .optionalCounter:
                return .none
            }
        }
        .ifLet(\.optionalCounter, action: /Action.optionalCounter) {
            Counter()
        }
    }
}

struct OptionalCounterView: View {
    let store: StoreOf<OptionalCounter>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Button("Toggle counter state") {
                    viewStore.send(.toggleCounterButtonTapped)
                }
                
                IfLetStore(
                    store.scope(state: \.optionalCounter, action: OptionalCounter.Action.optionalCounter),
                    then: {
                        Text("CounterState is non-nil")
                        CounterView(store: $0)
                            .buttonStyle(.borderless)
                            .frame(maxWidth: .infinity)
                    },
                    else: {
                        Text("CounterState is nil")
                    }
                )
            }
        }
    }
}

struct OptionalCounterView_Previews: PreviewProvider {
    static var previews: some View {
        OptionalCounterView(store: Store(initialState: OptionalCounter.State()) {
            OptionalCounter()
        })
    }
}
