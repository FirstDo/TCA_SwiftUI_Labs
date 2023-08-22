import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct IndexCoordinator: Reducer {
    struct State: Equatable, IndexedRouterState {
        static let initialState = State(routes: [.root(.home(.init()), embedInNavigationView: true)])
        var routes: [Route<Screen.State>]
    }
    
    enum Action: IndexedRouterAction {
        case routeAction(Int, action: Screen.Action)
        case updateRoutes([Route<Screen.State>])
    }
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .routeAction(_, action: .home(.startTapped)):
                state.routes.presentSheet(.numbersList(.init(numbers: Array(0..<4))), embedInNavigationView: true)
                return .none
                
            case let .routeAction(_, action: .numbersList(.numberSelected(number))):
                state.routes.push(.numberDetail(.init(number: number)))
                return .none
                
            case let .routeAction(_, action: .numberDetail(.showDouble(number))):
                state.routes.presentSheet(.numberDetail(.init(number: number * 2)), embedInNavigationView: true)
                return .none
                
            case .routeAction(_, action: .numberDetail(.goBackTapped)):
                state.routes.goBack()
                return .none
                
            case .routeAction(_, action: .numberDetail(.goBackToNumbersList)):
                return .routeWithDelaysIfUnsupported(state.routes) {
                    $0.goBackTo(/Screen.State.numbersList)
                }
                
            case .routeAction(_, action: .numberDetail(.goBackToRootTapped)):
                return .routeWithDelaysIfUnsupported(state.routes) {
                    $0.goBackToRoot()
                }
                
            default:
                return .none
            }
        }
        .forEachRoute {
            Screen()
        }
    }
}

struct IndexCoordinatorView: View {
    let store: StoreOf<IndexCoordinator>
    
    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) { screen in
                switch screen {
                case .home:
                    CaseLet(/Screen.State.home, action: Screen.Action.home, then: HomeView.init)
                case .numbersList:
                    CaseLet(/Screen.State.numbersList, action: Screen.Action.numbersList, then: NumberListView.init)
                case .numberDetail:
                    CaseLet(/Screen.State.numberDetail, action: Screen.Action.numberDetail, then: NumberDetailView.init)
                }
            }
        }
    }
}
