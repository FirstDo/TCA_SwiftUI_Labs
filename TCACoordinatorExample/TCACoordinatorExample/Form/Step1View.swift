import SwiftUI
import ComposableArchitecture

struct Step1Core: Reducer {
  struct State: Equatable {
    @BindingState var firstName = ""
    @BindingState var lastName = ""
  }
  
  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case nextButtonTapped
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
  }
}

struct Step1View: View {
  let store: StoreOf<Step1Core>
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Form {
        TextField("First Name", text: viewStore.$firstName)
        TextField("Last Name", text: viewStore.$lastName)
        
        Section {
          Button("Next") {
            viewStore.send(.nextButtonTapped)
          }
        }
      }
      .navigationTitle("Step 1")
    }
  }
}

#Preview {
  Step1View(store: .init(initialState: .init()) { Step1Core() })
}
