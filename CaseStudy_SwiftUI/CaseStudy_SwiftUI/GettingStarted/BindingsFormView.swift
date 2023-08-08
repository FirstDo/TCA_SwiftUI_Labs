import SwiftUI
import ComposableArchitecture

struct BindingsForm: Reducer {
    struct State: Equatable {
        @BindingState var sliderValue = 5.0
        @BindingState var stepCount = 10
        @BindingState var text = ""
        @BindingState var toggleIsOn = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case resetButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$stepCount):
                state.sliderValue = .minimum(state.sliderValue, Double(state.stepCount))
                return .none
            case .binding:
                return .none
            case .resetButtonTapped:
                state = State()
                return .none
            }
        }
    }
}

struct BindingsFormView: View {
    let store: StoreOf<BindingsForm>
    
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                TextField("Type here", text: viewStore.$text)
                    .autocorrectionDisabled(true)
                    .foregroundStyle(viewStore.toggleIsOn ? .secondary : .primary)
                    .disabled(viewStore.toggleIsOn)
                
                Toggle(
                    "Disable other controls",
                    isOn: viewStore.$toggleIsOn
                )
                
                Stepper(
                    "Max slider value: \(viewStore.stepCount)",
                    value: viewStore.$stepCount,
                    in: 0...100
                )
                .disabled(viewStore.toggleIsOn)
                
                HStack {
                    Text("Slider value: \(Int(viewStore.sliderValue))")
                    
                    Slider(value: viewStore.$sliderValue, in: 0...Double(viewStore.stepCount))
                        .tint(.accentColor)
                }
                .disabled(viewStore.toggleIsOn)
                
                Button("Reset") {
                    viewStore.send(.resetButtonTapped)
                }
                .tint(.red)
            }
        }
        .monospacedDigit()
        .navigationTitle("Bindings Form")
    }
}

struct BindingsFormView_Previews: PreviewProvider {
    static var previews: some View {
        BindingsFormView(
            store: Store(initialState: BindingsForm.State()) { BindingsForm() }
        )
    }
}
