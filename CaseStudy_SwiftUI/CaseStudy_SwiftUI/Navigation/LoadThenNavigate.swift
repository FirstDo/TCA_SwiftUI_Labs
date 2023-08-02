import SwiftUI
import ComposableArchitecture

struct LoadThenNavigate: ReducerProtocol {
    struct State: Equatable {
        var optionalCounter: Counter.State?
        var isIndicator = false
        var isNavigationActive: Bool {
            self.optionalCounter != nil
        }
    }
    
    enum Action: Equatable {
        case onDisappear
        case optionalCounter(Counter.Action)
        case setNavigation(isActive: Bool)
        case setNavigationIsActiveDelayCompleted
    }
    
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case load }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onDisappear:
                return .cancel(id: CancelID.load)
                
            case .setNavigation(isActive: true):
                state.isIndicator = true
                return .run { send in
                    try await clock.sleep(for: .seconds(2))
                    await send(.setNavigationIsActiveDelayCompleted)
                }
                .cancellable(id: CancelID.load)
                
            case .setNavigation(isActive: false):
                state.optionalCounter = nil
                return .none
                
            case .setNavigationIsActiveDelayCompleted:
                state.isIndicator = false
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

struct LoadThenNavigateView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct LoadThenNavigateView_Previews: PreviewProvider {
    static var previews: some View {
        LoadThenNavigateView()
    }
}
