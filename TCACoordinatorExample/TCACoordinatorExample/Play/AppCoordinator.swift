import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct GameApp: Reducer {
  struct State: Equatable {
    static let initialState = State(login: .initialState, game: .initalState, isLoggedIn: false)
    
    var login: LoginCoordinator.State
    var game: GameCoordinator.State
    
    var isLoggedIn: Bool
  }
  
  enum Action {
    case login(LoginCoordinator.Action)
    case game(GameCoordinator.Action)
  }
  
  var body: some ReducerOf<Self> {
    Scope(state: \.login, action: /Action.login) {
      LoginCoordinator()
    }
    
    Scope(state: \.game, action: /Action.game) {
      GameCoordinator()
    }
    
    Reduce { state, action in
      switch action {
      case .login(.routeAction(_, action: .logIn(.logInTapped))):
        state.game = .initalState
        state.isLoggedIn = true
        
      case .game(.routeAction(_, action: .game(.logOutButtonTapped))):
        state.login = .initialState
        state.isLoggedIn = false
        
      default:
        break
      }
      return .none
    }
  }
}

struct AppCoordinatorView: View {
  let store: StoreOf<GameApp>
  
  var body: some View {
    WithViewStore(store, observe: { $0.isLoggedIn }) { viewStore in
      VStack {
        if viewStore.state {
          GameCoordinatorView(store: store.scope(state: \.game, action: GameApp.Action.game))
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        } else {
          LoginCoordinatorView(store: store.scope(state: \.login, action: GameApp.Action.login))
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
      }
      .animation(.default, value: viewStore.state)
    }
  }
}
