import SwiftUI
import ComposableArchitecture

enum Job: String, CaseIterable {
  case iOS
  case Android
  case Web
  case Designer
}

struct Step3Core: Reducer {
  struct State: Equatable {
    @BindingState var date = Date.now
    var selectedJob: String?
  }
  
  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case jobTapped(String)
    case nextButtonTapped
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case let .jobTapped(job):
        if state.selectedJob == job {
          state.selectedJob = nil
        } else {
          state.selectedJob = job
        }
        
      default:
        break
      }
      return .none
    }
  }
}

struct Step3View: View {
  let store: StoreOf<Step3Core>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Form {
        Section {
          ForEach(Job.allCases, id: \.self) { title in
            Button {
              store.send(.jobTapped(title.rawValue))
            } label: {
              HStack {
                Text(title.rawValue)
                Spacer()
                if viewStore.selectedJob == title.rawValue {
                  Image(systemName: "checkmark")
                }
              }
            }
          }

        } header: {
          Text("Jobs")
        }
        
        Button("Next") {
          viewStore.send(.nextButtonTapped)
        }
      }
      .buttonStyle(.plain)
    }
  }
}

#Preview {
  Step3View(store: .init(initialState: .init()) { Step3Core() })
}
