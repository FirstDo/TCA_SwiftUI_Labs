import SwiftUI
import ComposableArchitecture

struct EffectsCancellation: Reducer {
    struct State: Equatable {
        var count = 0
        var numberFact: String?
        var isFactRequestInFlight = false
    }
    
    enum Action {
        case stepperChanged(Int)
        case numberFactTapped
        case cancelTapped
        case numberFactResult(TaskResult<String>)
    }
    
    @Dependency(\.factClient) var factClient
    private enum CancelID { case factRequest }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .stepperChanged(value):
            state.isFactRequestInFlight = false
            state.count = value
            return .cancel(id: CancelID.factRequest)
        case .numberFactTapped:
            state.numberFact = nil
            state.isFactRequestInFlight = true
            
            return .run { [count = state.count] send in
                await send(.numberFactResult(TaskResult {
                    try await factClient.fetch(count)
                }))
            }
            .cancellable(id: CancelID.factRequest)
            
        case .cancelTapped:
            state.isFactRequestInFlight = false
            return .cancel(id: CancelID.factRequest)
            
        case let .numberFactResult(.success(text)):
            state.numberFact = text
            state.isFactRequestInFlight = false
            return .none
            
        case .numberFactResult(.failure):
            state.isFactRequestInFlight = false
            return .none
        }
    }
}

struct EffectsCancellationView: View {
    let store: StoreOf<EffectsCancellation>
    @Environment(\.openURL) var openURL
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    Stepper(
                        "\(viewStore.count)",
                        value: viewStore.binding(
                            get: \.count,
                            send: EffectsCancellation.Action.stepperChanged
                        )
                    )
                    
                    if viewStore.isFactRequestInFlight == false {
                        Button("Number Fact") {
                            viewStore.send(.numberFactTapped)
                        }
                    } else {
                        HStack {
                            Button("Cancel") {
                                viewStore.send(.cancelTapped)
                            }
                            Spacer()
                            ProgressView()
                                .id(UUID())
                        }
                    }
                    
                    if let numberFact = viewStore.numberFact {
                        Text(numberFact)
                    }
                }
                
                Section {
                    Button("Number facts provided by numbersapi.com") {
                        self.openURL(URL(string: "http://numbersapi.com")!)
                    }
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderless)
        }
    }
}

struct EffectsCancellationView_Previews: PreviewProvider {
    static var previews: some View {
        EffectsCancellationView(store: Store(
            initialState: EffectsCancellation.State()) {
                EffectsCancellation()
            }
        )
    }
}
