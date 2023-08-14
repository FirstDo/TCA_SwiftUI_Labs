import ComposableArchitecture
import TCACoordinators

struct Screen: Reducer {
    enum State: Equatable {
        case home(Home.State)
        case numberList(NumberList.State)
        case numberDetail(NumberDetail.State)
    }
    
    enum Action {
        case home(Home.Action)
        case numberList(NumberList.Action)
        case numberDetail(NumberDetail.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.home, action: /Action.home) {
            Home()
        }
        Scope(state: /State.numberList, action: /Action.numberList) {
            NumberList()
        }
        Scope(state: /State.numberDetail, action: /Action.numberDetail) {
            NumberDetail()
        }
    }
}

struct Coordinator: Reducer {
    struct State: Equatable, IndexedRouterState {
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
                state.routes.presentSheet(.numberList(.init(numbers: Array(0..<4))), embedInNavigationView: true)
                
            case .routeAction(_, action: .numberList(.numberSelected(let number))):
                state.routes.push(.numberDetail(.init(number: number)))
                
            case .routeAction(_, action: .numberDetail(.showDouble(let number))):
                state.routes.presentSheet(.numberDetail(.init(number: number * 2)))
                
            case .routeAction(_, action: .numberDetail(.goBackTapped)):
                state.routes.goBack()
                
            case .routeAction(_, action: .numberDetail(.goBackToNumberList)):
                return .routeWithDelaysIfUnsupported(state.routes) {
                    $0.goBackTo(/Screen.State.numberList)
                }
            
            case .routeAction(_, action: .numberDetail(.goBatkToRootTapped)):
                return .routeWithDelaysIfUnsupported(state.routes) {
                    $0.goBackToRoot()
                }
            default:
                break
            }
            
            return .none
        }.forEachRoute {
            Screen()
        }
    }
}
