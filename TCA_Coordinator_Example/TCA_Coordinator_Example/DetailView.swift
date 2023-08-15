import SwiftUI
import ComposableArchitecture

struct Detail: Reducer {
  struct State: Equatable {
    let num: Int
  }
  
  enum Action: Equatable {
    case backButtonTapped
  }
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .backButtonTapped:
      return .none
    }
  }
}

struct DetailView: View {
  let store: StoreOf<Detail>
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Text("\(viewStore.num)")
        Button("Go Back") {
          store.send(.backButtonTapped)
        }
      }
    }
  }
}

struct DetailView_Previews: PreviewProvider {
  static var previews: some View {
    DetailView(
      store: .init(initialState: Detail.State(num: 5)) {
          Detail()
      }
    )
  }
}
