import SwiftUI
import ComposableArchitecture

struct Effects_Basics: Reducer {
    struct State: Equatable {
        var count = 0
        var isNumberFactRequestInFlight = false
        var numberFact: String?
    }
    
    enum Action {
        case decrementButtonTapped
        case decrementDelayResponse
        case incrementButtonTapped
        case numberFactButtonTapped
        case numberFactResponse(TaskResult<String>)
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.factClient) var factClient
    
    private enum CancelID { case delay }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .decrementButtonTapped:
            state.count -= 1
            state.numberFact = nil
            
            return state.count >= 0
            ? .none
            : .run { send in
                try await clock.sleep(for: .seconds(1))
                await send(.decrementDelayResponse)
            }
            .cancellable(id: CancelID.delay)
            
            
        case .decrementDelayResponse:
            if state.count < 0 {
                state.count += 1
            }
            return .none
            
        case .incrementButtonTapped:
            state.count += 1
            state.numberFact = nil
            
            return state.count >= 0
            ? .cancel(id: CancelID.delay)
            : .none
            
        case .numberFactButtonTapped:
            state.isNumberFactRequestInFlight = true
            state.numberFact = nil
            
            return .run { [count = state.count] send in
                await send(.numberFactResponse(
                    TaskResult { try await self.factClient.fetch(count) }
                ))
            }
            
        case let .numberFactResponse(.success(response)):
            state.isNumberFactRequestInFlight = false
            state.numberFact = response
            return .none
            
        case .numberFactResponse(.failure):
            state.isNumberFactRequestInFlight = false
            return .none
        }
    }
}

struct Effects_BasicsView: View {
    let store: StoreOf<Effects_Basics>
    @Environment(\.openURL) var openURL
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    HStack {
                        Button {
                            viewStore.send(.decrementButtonTapped)
                        } label: {
                            Image(systemName: "minus")
                        }
                        
                        Text(viewStore.count, format: .number)
                            .monospacedDigit()
                        
                        Button {
                            viewStore.send(.incrementButtonTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button("Number fact") {
                        viewStore.send(.numberFactButtonTapped)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    if viewStore.isNumberFactRequestInFlight {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .id(UUID())
                    }
                    
                    if let numberFact = viewStore.numberFact {
                        Text(numberFact)
                    }
                }
                
                Section {
                    Button("Number facts provided by numbersapi.com") {
                        openURL(URL(string: "http://numbersapi.com")!)
                    }
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderless)
        }
        .navigationTitle("Effects")
    }
}

struct Effects_BasicsView_Previews: PreviewProvider {
    static var previews: some View {
        Effects_BasicsView(store: Store(
            initialState: Effects_Basics.State()) {
                Effects_Basics()
            }
        )
    }
}
