import SwiftUI
import ComposableArchitecture

struct Home: Reducer {
  struct State: Equatable {
    var nums: [Int]
    
    init(nums: [Int] = Array(1...10)) {
      self.nums = nums
    }
  }
  
  enum Action: Equatable {
    case itemTapped(Int)
  }
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case let .itemTapped(num):
      return .none
    }
  }
}

struct HomeView: View {
  let store: StoreOf<Home>
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        ForEach(viewStore.nums, id: \.self) { num in
          Button {
            store.send(.itemTapped(num))
          } label: {
            Text("\(num)")
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(
      store: .init(initialState: Home.State()) {
        Home()
      }
    )
  }
}
