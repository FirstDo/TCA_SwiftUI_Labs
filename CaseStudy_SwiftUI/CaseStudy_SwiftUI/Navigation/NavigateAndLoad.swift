import SwiftUI
import ComposableArchitecture

struct NavigateAndLoad: ReducerProtocol {
    struct State: Equatable {
        var isNavigationActive = false
        var optionalCounter: Counter.State?
    }
    
    enum Action {
        case optionalCounter(Counter.Action)
        case setNavigation(isActive: Bool)
        case setNavigationIsActiveDelayCompleted
    }
    
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case load }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .setNavigation(isActive: true):
                state.isNavigationActive = true
                return .run { send in
                    try await self.clock.sleep(for: .seconds(1))
                    await send(.setNavigationIsActiveDelayCompleted)
                }
                .cancellable(id: CancelID.load)
                
            case .setNavigation(isActive: false):
                state.isNavigationActive = false
                state.optionalCounter = nil
                return .cancel(id: CancelID.load)
                
            case .setNavigationIsActiveDelayCompleted:
                state.optionalCounter = Counter.State()
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

struct NavigateAndLoadView: View {
    let store: StoreOf<NavigateAndLoad>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                NavigationLink(
                    destination: IfLetStore(
                        self.store.scope(
                            state: \.optionalCounter,
                            action: NavigateAndLoad.Action.optionalCounter
                        )
                    ) {
                        CounterView(store: $0)
                    } else: {
                        ProgressView()
                    },
                    isActive: viewStore.binding(get: \.isNavigationActive, send: NavigateAndLoad.Action.setNavigation(isActive:))) {
                        Text("Load optional counter")
                    }
            }
        }
        .navigationTitle("Navigate and load")
    }
}

struct NavigateAndLoadView_Previews: PreviewProvider {
    static var previews: some View {
        NavigateAndLoadView(store: Store(
            initialState: .init(),
            reducer: NavigateAndLoad()
        ))
    }
}
