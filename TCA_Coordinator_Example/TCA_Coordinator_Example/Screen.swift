import ComposableArchitecture
import TCACoordinators

struct Screen: Reducer {
  enum State: Equatable {
    case home(Home.State)
    case detail(Detail.State)
  }
  
  enum Action: Equatable {
    case home(Home.Action)
    case detail(Detail.Action)
  }
  
  var body: some ReducerOf<Self> {
    Scope(state: /State.home, action: /Action.home) {
      Home()
    }
    
    Scope(state: /State.detail, action: /Action.detail) {
      Detail()
    }
  }
}
