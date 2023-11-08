import SwiftUI
import ComposableArchitecture

struct Step2Core: Reducer {
  struct State: Equatable {
    @BindingState var date = Date.now
  }
  
  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case nextButtonTapped
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
  }
}

struct Step2View: View {
  let store: StoreOf<Step2Core>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Form {
        Section {
          DatePicker(
            "Date of Birth",
            selection: viewStore.$date,
            in: ...Date.now,
            displayedComponents: .date
          )
          .datePickerStyle(.graphical)
        } header: {
          Text("Date of Birth")
        }
        
        Button("Next") {
          viewStore.send(.nextButtonTapped)
        }
      }
    }
  }
}

#Preview {
  Step2View(store: .init(initialState: .init()) { Step2Core() })
}
