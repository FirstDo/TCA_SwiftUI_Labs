import SwiftUI
import ComposableArchitecture

struct Bindings: Reducer {
    struct State: Equatable {
        var sliderValue = 5.0
        var stepCount = 10
        var text = ""
        var toggleIsOn = false
    }
    
    enum Action {
        case sliderValueChanged(Double)
        case stepCountChanged(Int)
        case textChanged(String)
        case toggleChanged(isOn: Bool)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .sliderValueChanged(value):
            state.sliderValue = value
            return .none
            
        case let .stepCountChanged(count):
            state.sliderValue = .minimum(state.sliderValue, Double(count))
            state.stepCount = count
            return .none
            
        case let .textChanged(text):
            state.text = text
            return .none
            
        case let .toggleChanged(isOn):
            state.toggleIsOn = isOn
            return .none
        }
    }
}

struct BindingsView: View {
    let store: StoreOf<Bindings>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                TextField("Type here", text: viewStore.binding(get: \.text, send: Bindings.Action.textChanged))
                    .autocorrectionDisabled(true)
                    .foregroundStyle(viewStore.toggleIsOn ? .secondary : .primary)
                    .disabled(viewStore.toggleIsOn)
                
                Toggle("Disable other controls", isOn: viewStore.binding(
                    get: \.toggleIsOn,
                    send: Bindings.Action.toggleChanged
                ))
                
                Stepper(
                    "Max Slider value: \(viewStore.stepCount)",
                    value: viewStore.binding(get: \.stepCount, send: Bindings.Action.stepCountChanged),
                    in: 0...100
                )
                .disabled(viewStore.toggleIsOn)
                
                HStack {
                    Text("Slider value: \(Int(viewStore.sliderValue))")
                    Slider(
                        value: viewStore.binding(get: \.sliderValue, send: Bindings.Action.sliderValueChanged),
                        in: 0...Double(viewStore.stepCount)
                    )
                    .tint(.accentColor)
                    .disabled(viewStore.toggleIsOn)
                }
            }
            .monospacedDigit()
            .navigationTitle("Bindings")
        }
    }
}
