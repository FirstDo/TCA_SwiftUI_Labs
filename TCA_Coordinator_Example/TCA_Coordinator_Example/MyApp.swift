import SwiftUI
import ComposableArchitecture
import TCACoordinators

@main
struct TCA_Coordinator_ExampleApp: App {
    var body: some Scene {
        WindowGroup {
          MainTabCoordinatorView(store: .init(initialState: .initialState) {
            MainTabCoordinator()
          })
        }
    }
}

struct MainTabCoordinatorView: View {
  let store: StoreOf<MainTabCoordinator>
  
  var body: some View {
    WithViewStore(store, observe: \.selectedTab) { viewStore in
      TabView(selection: viewStore.binding(get: { $0 }, send: MainTabCoordinator.Action.tabSelected)) {
        IdentifiedCoordinatorView(store: store.scope(state: { $0.identified }, action: { .identified($0)}))
          .tabItem { Text("Identified") }
          .tag(MainTabCoordinator.Tab.identified)
      }
    }
  }
}

struct MainTabCoordinator: Reducer {
  enum Tab: Hashable {
    case identified, indexed, app, form, deeplinkOpened
  }
  
  enum Deeplink {
    case identified(IdentifiedCoordinator.Deeplink)
  }
  
  enum Action {
    case identified(IdentifiedCoordinator.Action)
    case deeplinkOpened(Deeplink)
    case tabSelected(Tab)
  }
  
  struct State: Equatable {
    
    static let initialState = State(identified: .initialState, selectedTab: .app)
    
    var identified: IdentifiedCoordinator.State
    var selectedTab: Tab
  }
  
  var body: some ReducerOf<Self> {
    Scope(state: \.identified, action: /Action.identified) {
      IdentifiedCoordinator()
    }
    
    Reduce { state, action in
      switch action {
      case let .deeplinkOpened(.identified(.showNumber(number))):
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
