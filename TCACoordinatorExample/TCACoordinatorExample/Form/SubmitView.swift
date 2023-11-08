import SwiftUI
import ComposableArchitecture

struct SubmitCore: Reducer {
  struct State: Equatable {
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
    let job: String?
    
    var isNotComplete: Bool {
      firstName.isEmpty || lastName.isEmpty || (job?.isEmpty ?? true)
    }
  }
  
  enum Action: Equatable {
    case returnToName
    case returnToDateOfBirth
    case returToJob
    
    case submit
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      default:
        return .none
      }
    }
  }
}

struct SubmitView: View {
  let store: StoreOf<SubmitCore>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Form {
        Section {
          Button {
            store.send(.returnToName)
          } label: {
            HStack {
              Text("FirstName")
              Spacer()
              Text(viewStore.firstName)
                .foregroundColor(viewStore.firstName.isEmpty ? .red : .black)
            }
            .contentShape(Rectangle())
          }
          
          Button {
            store.send(.returnToName)
          } label: {
            HStack {
              Text("LastName")
              Spacer()
              Text(viewStore.lastName)
                .foregroundColor(viewStore.lastName.isEmpty ? .red : .black)
            }
            .contentShape(Rectangle())
          }
          
          Button {
            store.send(.returnToDateOfBirth)
          } label: {
            HStack {
              Text("Birth")
              Spacer()
              Text(viewStore.dateOfBirth, format: .dateTime.day().month().year())
            }
            .contentShape(Rectangle())
          }
          
          Button {
            store.send(.returToJob)
          } label: {
            HStack {
              Text("Job")
              Spacer()
              Text(viewStore.job ?? "no job")
                .foregroundColor(viewStore.job?.isEmpty == true ? .red : .black)
            }.contentShape(Rectangle())
          }

        } header: {
          Text("Confirm your info")
        }
        
        Button("Submit") {
          store.send(.submit)
        }
        .disabled(viewStore.isNotComplete)
      }
      .buttonStyle(.plain)
    }
  }
}

#Preview {
  SubmitView(store: .init(initialState: .init(firstName: "", lastName: "", dateOfBirth: .now, job: nil)) { SubmitCore() })
}
