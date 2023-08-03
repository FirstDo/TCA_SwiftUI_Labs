import SwiftUI
import ComposableArchitecture

struct LoadThenPresent: ReducerProtocol {
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
    
    var body: some ReducerProtocol<State, Action> {
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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct LoadThenPresentView_Previews: PreviewProvider {
    static var previews: some View {
        LoadThenPresentView(store: Store(
            initialState: .init(),
            reducer: LoadThenPresent()
        ))
    }
}
