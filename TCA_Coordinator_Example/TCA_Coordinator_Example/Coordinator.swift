import ComposableArchitecture
import TCACoordinators
import SwiftUI

struct Coordinator: Reducer {
  struct State: Equatable, IndexedRouterState {
    var routes: [Route<Screen.State>]
    
    init(routes: [Route<Screen.State>] = [.root(.home(.init()), embedInNavigationView: true)]) {
      self.routes = routes
    }
  }
  
  enum Action: IndexedRouterAction, Equatable {
    case routeAction(Int, action: Screen.Action)
    case updateRoutes([Route<Screen.State>])
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .routeAction(_, action: .home(.itemTapped(num))):
        state.routes.push(.detail(.init(num: num)))
        return .none
        
      case .routeAction(_, action: .detail(.backButtonTapped)):
        state.routes.pop()
        return .none
        
      default:
        return .none
      }
    }
  }
}

struct CoordinatorView: View {
  let store: StoreOf<Coordinator>
  var body: some View {
    TCARouter(store) { screenStore in
      SwitchStore(screenStore) { state in
        switch state {
        case .home:
          CaseLet(/Screen.State.home, action: Screen.Action.home, then: HomeView.init)
        case .detail:
          CaseLet(/Screen.State.detail, action: Screen.Action.detail, then: DetailView.init)
        }
      }
    }
  }
}
