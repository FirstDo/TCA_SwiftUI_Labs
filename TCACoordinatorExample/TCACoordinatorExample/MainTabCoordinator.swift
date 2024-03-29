import SwiftUI

import ComposableArchitecture
import TCACoordinators

struct MainTabCoordinatorView: View {
  let store: StoreOf<MainTabCoordinator>
  
  var body: some View {
    WithViewStore(store, observe: \.selectedTab) { viewStore in
      TabView(selection: viewStore.binding(get: { $0 }, send: MainTabCoordinator.Action.tabSelected)) {
        IndexedCoordinatorView(store: store.scope(state: { $0.indexed }, action: { .indexed($0) }))
          .tabItem { Text("Indexed") }
          .tag(MainTabCoordinator.Tab.indexed)
        
        IdentifiedCoordinatorView(store: store.scope(state: { $0.identified}, action: { .identified($0) }))
          .tabItem { Text("Identified") }
          .tag(MainTabCoordinator.Tab.identified)
        
        StepCoordinatorView(store: store.scope(state: { $0.step }, action: { .step($0)}))
          .tabItem { Text("Step") }
          .tag(MainTabCoordinator.Tab.step)
        
        AppCoordinatorView(store: store.scope(state: \.game, action: { .game($0) }))
          .tabItem { Text("Game") }
          .tag(MainTabCoordinator.Tab.game)
      }
    }
  }
}

struct MainTabCoordinator: Reducer {
  enum Tab: Hashable {
    case indexed
    case identified
    case step
    case game
  }
  
  enum DeepLink {
    case identified(IdentifiedCoordinator.DeepLink)
  }
  
  enum Action {
    case indexed(IndexedCoordinator.Action)
    case identified(IdentifiedCoordinator.Action)
    case step(StepCoordinator.Action)
    case game(GameApp.Action)
    case depplinkOpened(DeepLink)
    case tabSelected(Tab)
  }
  
  struct State: Equatable {
    static let initialState = State(
      indexed: .initialState,
      identified: .initialState,
      step: .initialState,
      game: .initialState,
      selectedTab: .indexed
    )
    
    var indexed: IndexedCoordinator.State
    var identified: IdentifiedCoordinator.State
    var step: StepCoordinator.State
    var game: GameApp.State
    
    var selectedTab: Tab
  }
  
  var body: some ReducerOf<Self> {
    Scope(state: \.indexed, action: /Action.indexed) {
      IndexedCoordinator()
    }
    
    Scope(state: \.identified, action: /Action.identified) {
      IdentifiedCoordinator()
    }
    
    Scope(state: \.step, action: /Action.step) {
      StepCoordinator()
    }
    
    Scope(state: \.game, action: /Action.game) {
      GameApp()
    }
    
    Reduce { state, action in
      switch action {
      case let .depplinkOpened(.identified(.showNumber(number))):
        state.selectedTab = .identified
        
        if state.identified.routes.canPush == true {
          state.identified.routes.push(.numberDetail(.init(number: number)))
        } else {
          state.identified.routes.presentSheet(.numberDetail(.init(number: number)), embedInNavigationView: true)
        }
        
      case let .tabSelected(tab):
        state.selectedTab = tab
        
      default:
        break
      }
      
      return .none
    }
  }
}
