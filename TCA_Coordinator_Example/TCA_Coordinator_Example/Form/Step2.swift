import ComposableArchitecture
import SwiftUI

struct Step2: Reducer {
    struct State: Equatable {
        @BindingState var dateOfBirth: Date = .now
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case nextButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
    }
}

struct Step2View: View {
    let store: StoreOf<Step2>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section("Date of Birth") {
                    DatePicker(
                        "Date of Birth",
                        selection: viewStore.$dateOfBirth,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }
                
                Button("Next") {
                    viewStore.send(.nextButtonTapped)
                }
            }
            .navigationTitle("Step 2")
        }
    }
}

struct Step2View_Previews: PreviewProvider {
    static var previews: some View {
        Step2View(store: .init(initialState: .init()) {
            Step2()
        })
    }
}
