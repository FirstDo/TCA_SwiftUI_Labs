import SwiftUI
import ComposableArchitecture

struct Game: Reducer {
  struct State: Equatable {
    let id = UUID()
    let number = Int.random(in: 0...100)
  }
  
  enum Action: Equatable {
    case playAgainButtonTap
    case logOutButtonTapped
  }
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .playAgainButtonTap:
      return .none
      
    case .logOutButtonTapped:
      return .none
    }
  }
}

struct GameView: View {
  let store: StoreOf<Game>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Text("\(viewStore.number)")
        Button("play again") {
          store.send(.playAgainButtonTap)
        }
        
        Button("Log out") {
          store.send(.logOutButtonTapped)
        }
      }
      .buttonStyle(.borderedProminent)
    }
  }
}
