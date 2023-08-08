import SwiftUI
import ComposableArchitecture

struct LoadThenPresent: Reducer {
    struct State: Equatable {
        @PresentationState var counter: Counter.State?
        var isActivityIndicatorVisable = false
    }
    
    enum Action {
        case counter(PresentationAction<Counter.Action>)
        case counterButtonTapped
        case counterPresentationDelayCompleted
    }
    
    @Dependency(\.continuousClock) var clock
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .counter:
                return .none
                
            case .counterButtonTapped:
                state.isActivityIndicatorVisable = true
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    await send(.counterPresentationDelayCompleted)
                }
                
            case .counterPresentationDelayCompleted:
                state.isActivityIndicatorVisable = false
                state.counter = .init()
                return .none
            }
        }
        .ifLet(\.$counter, action: /Action.counter) {
            Counter()
        }
    }
}

struct LoadThenPresentView: View {
    let store: StoreOf<LoadThenPresent>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Button {
                    viewStore.send(.counterButtonTapped)
                } label: {
                    HStack {
                        Text("Load optional counter")
                        if viewStore.isActivityIndicatorVisable {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }
            .sheet(
                store: store.scope(state: \.$counter, action: LoadThenPresent.Action.counter),
                content: CounterView.init(store:)
            )
            .navigationTitle("Load and present")
        }
    }
}

struct LoadThenPresentView_Previews: PreviewProvider {
    static var previews: some View {
        LoadThenPresentView(store: Store(
            initialState: .init()) { LoadThenPresent() }
        )
    }
}
