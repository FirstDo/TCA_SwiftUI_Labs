import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct Coordinator: Reducer {
    struct State: Equatable, IndexedRouterState {
        var routes: [Route<Screen.State>]
        
        init(routes: [Route<Screen.State>] = [.root(.main(.init()), embedInNavigationView: true)]) {
            self.routes = routes
        }
    }
    
    enum Action: Equatable, IndexedRouterAction {
        case routeAction(Int, action: Screen.Action)
        case updateRoutes([Route<Screen.State>])
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeAction(_, action: .main(.buttonTapped)):
                state.routes.push(.detail(.init()))
                return .none
                
            case .routeAction(_, action: .detail(.increaseNumber)):
                // 화면전환 로직이 아닌데, 여기서..? 상위 State를 찾아서 그거 조작하는게 맞나..?
                return .none
                
            case .routeAction(_, action: .detail(.backButtonTapped)):
                state.routes.pop()
                return .none
                
            case let .updateRoutes(route):
                state.routes = route
                return .none
                
            default:
                return .none
            }
        }
        .forEachRoute {
            Screen()
        }
    }
}

struct CoordinatorView: View {
    let store: StoreOf<Coordinator>
    
    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) { initialState in
                switch initialState {
                case .main:
                    CaseLet(/Screen.State.main, action: Screen.Action.main, then: MainView.init)
                case .detail:
                    CaseLet(/Screen.State.detail, action: Screen.Action.detail, then: DetailView.init)
                }
            }
        }
    }
}
