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
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
