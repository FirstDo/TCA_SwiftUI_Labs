import SwiftUI
import ComposableArchitecture

struct NavigationDemo: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct NavigationDeom_Previews: PreviewProvider {
    static var previews: some View {
      NavigationDemo()
    }
}

struct ScreenA: ReducerProtocol {
  struct State: Equatable {
    var count = 0
    var fact: String?
    var isLoading = false
  }
  
  enum Action: Equatable {
    case decrementButtonTapped
    case dismissButtonTapped
    case incrementButtonTapped
    case factButtonTapped
    case factResponse(TaskResult<String>)
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.factClient) var factClient
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .decrementButtonTapped:
      state.count -= 1
      return .none
      
    case .dismissButtonTapped:
      return .run { _ in
        await self.dismiss()
      }
      
    case .incrementButtonTapped:
      state.count += 1
      return .none
      
    case .factButtonTapped:
      state.isLoading = true
      return .run { [count = state.count] send in
        await send(.factResponse(TaskResult {
          try await self.factClient.fetch(count)
        }))
      }
      
    case let .factResponse(.success(fact)):
      state.isLoading = false
      state.fact = fact
      return .none
      
    case .factResponse(.failure):
      state.isLoading = false
      state.fact = nil
      return .none
    }
  }
}
