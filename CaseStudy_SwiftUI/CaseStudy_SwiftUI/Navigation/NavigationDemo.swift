import SwiftUI
import ComposableArchitecture

struct NavigationDemo: ReducerProtocol {
    struct State: Equatable {
        var path = StackState<Path.State>()
    }
    
    enum Action {
        
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
    
    struct Path: ReducerProtocol {
        enum State: Equatable {
            case screenA(ScreenA.State = .init())
            case screenB(ScreenB.State = .init())
            case screenC
        }
        
        enum Action {
            case screenA(ScreenA.Action)
            case screenB(ScreenB.Action)
            case screenC
        }
        
        var body: some ReducerProtocol<State, Action> {
            Scope(state: /State.screenA, action: /Action.screenA) {
                ScreenA()
            }
            Scope(state: /State.screenB, action: /Action.screenB) {
                ScreenB()
            }
        }
    }
}

struct NavigationDemoView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct NavigationDemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationDemoView()
    }
}

// MARK: - Screen B

struct ScreenB: ReducerProtocol {
    struct State :Equatable { }
    
    enum Action {
        case screenAButtonTapped
        case screenBButtonTapped
        case screenCButtonTapped
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .screenAButtonTapped:
            return .none
        case .screenBButtonTapped:
            return .none
        case .screenCButtonTapped:
            return .none
        }
    }
}

struct ScreenBView: View {
    let store: StoreOf<ScreenB>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button("Decoupled navigation to screen A") {
                viewStore.send(.screenAButtonTapped)
            }
            Button("Decoupled navigation to screen B") {
                viewStore.send(.screenBButtonTapped)
            }
            Button("Decoupled navigation to screen C") {
                viewStore.send(.screenCButtonTapped)
            }
        }
        .navigationTitle("Screen B")
    }
}



// MARK: - Screen A

struct ScreenA: ReducerProtocol {
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isLoading = false
    }
    
    enum Action: Equatable {
        case decrementButtonTapped
        case dismissButtonTapped
        case incrementButtonTapped
        case factButtonTapped
        case factResponse(TaskResult<String>)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.factClient) var factClient
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .decrementButtonTapped:
            state.count -= 1
            return .none
            
        case .dismissButtonTapped:
            return .run { _ in
                await self.dismiss()
            }
            
        case .incrementButtonTapped:
            state.count += 1
            return .none
            
        case .factButtonTapped:
            state.isLoading = true
            return .run { [count = state.count] send in
                await send(.factResponse(TaskResult {
                    try await self.factClient.fetch(count)
                }))
            }
            
        case let .factResponse(.success(fact)):
            state.isLoading = false
            state.fact = fact
            return .none
            
        case .factResponse(.failure):
            state.isLoading = false
            state.fact = nil
            return .none
        }
    }
}

struct ScreenAView: View {
    let store: StoreOf<ScreenA>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    HStack {
                        Text("\(viewStore.count))")
                        Spacer()
                        Button {
                            viewStore.send(.decrementButtonTapped)
                        } label: {
                            Image(systemName: "minus")
                        }
                        Button {
                            viewStore.send(.incrementButtonTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    
                    Button {
                        viewStore.send(.factButtonTapped)
                    } label: {
                        HStack {
                            Text("Get fact")
                            if viewStore.isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    
                    if let fact = viewStore.fact {
                        Text(fact)
                    }
                }
                
                Section {
                    Button("Dismiss") {
                        viewStore.send(.dismissButtonTapped)
                    }
                }
                
                Section {
                    NavigationLink(
                        "Go to screen A",
                        state: NavigationDemo.Path.State.screenA(
                            .init(count: viewStore.count)
                        )
                    )
                    NavigationLink(
                        "Go to screen B",
                        state: NavigationDemo.Path.State.screenB()
                    )
                    //          NavigationLink(
                    //            "Go to screen C",
                    //            state: NavigationDemo.Path.State.screenC(
                    //              .init(count: viewStore.count)
                    //            )
                    //          )
                }
            }
            .buttonStyle(.borderless)
        }
    }
}
