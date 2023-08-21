import SwiftUI
import ComposableArchitecture

struct Step1: Reducer {
    struct State: Equatable {
        @BindingState var firstName = ""
        @BindingState var lastName = ""
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case nextButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
    }
}

struct Step1View: View {
    let store: StoreOf<Step1>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                TextField("First Name", text: viewStore.$firstName)
                TextField("First Name", text: viewStore.$lastName)
                
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

struct Step1View_Previews: PreviewProvider {
    static var previews: some View {
        Step1View(store: .init(initialState: .init()) {
            Step1()
        })
    }
}
