import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct GameScreen: Reducer {
  enum State: Equatable, Identifiable {
    case game(Game.State)
    
    var id: UUID {
      switch self {
      case .game(let state):
        return state.id
      }
    }
  }
  
  enum Action {
    case game(Game.Action)
  }
  
  var body: some ReducerOf<Self> {
    Scope(state: /State.game, action: /Action.game) {
      Game()
    }
  }
}

struct GameCoordinator: Reducer {
  struct State: Equatable, IdentifiedRouterState {
    static let initalState = GameCoordinator.State(routes: [
      .root(.game(.init()), embedInNavigationView: true)
    ])
    var routes: IdentifiedArrayOf<Route<GameScreen.State>>
  }
  
  enum Action: IdentifiedRouterAction {
    case routeAction(GameScreen.State.ID, action: GameScreen.Action)
    case updateRoutes(IdentifiedArrayOf<Route<GameScreen.State>>)
  }
  
  var body: some ReducerOf<Self> {
    EmptyReducer()
      .forEachRoute {
        GameScreen()
      }
  }
}

struct GameCoordinatorView: View {
  let store: StoreOf<GameCoordinator>
  
  var body: some View {
    TCARouter(store) { screen in
      SwitchStore(screen) { screen in
        switch screen {
        case .game:
          CaseLet(
            /GameScreen.State.game,
             action: GameScreen.Action.game,
             then: GameView.init
          )
        }
      }
    }
  }
}
