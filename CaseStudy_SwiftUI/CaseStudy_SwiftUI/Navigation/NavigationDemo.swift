import SwiftUI
import ComposableArchitecture

struct NavigationDemo: Reducer {
    struct State: Equatable {
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case goBackToScreen(id: StackElementID)
        case goToABCButtonTapped
        case path(StackAction<Path.State, Path.Action>)
        case popToRoot
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .goBackToScreen(id):
                state.path.pop(to: id)
                return .none
                
            case .goToABCButtonTapped:
                state.path.append(.screenA())
                state.path.append(.screenB())
                state.path.append(.screenC())
                return .none
                
            case let .path(action):
                switch action {
                case .element(id: _, action: .screenB(.screenAButtonTapped)):
                    state.path.append(.screenA())
                    return .none
                    
                case .element(id: _, action: .screenB(.screenBButtonTapped)):
                    state.path.append(.screenB())
                    return .none
                    
                case .element(id: _, action: .screenB(.screenCButtonTapped)):
                    state.path.append(.screenC())
                    return .none
                    
                default:
                    return .none
                }
                
            case .popToRoot:
                state.path.removeAll()
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
    
    struct Path: Reducer {
        enum State: Equatable {
            case screenA(ScreenA.State = .init())
            case screenB(ScreenB.State = .init())
            case screenC(ScreenC.State = .init())
        }
        
        enum Action {
            case screenA(ScreenA.Action)
            case screenB(ScreenB.Action)
            case screenC(ScreenC.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: /State.screenA, action: /Action.screenA) {
                ScreenA()
            }
            Scope(state: /State.screenB, action: /Action.screenB) {
                ScreenB()
            }
            Scope(state: /State.screenC, action: /Action.screenC) {
                ScreenC()
            }
        }
    }
}

struct NavigationDemoView: View {
    let store: StoreOf<NavigationDemo>
    var body: some View {
        NavigationStackStore(
            self.store.scope(state: \.path, action: NavigationDemo.Action.path)
        ) {
            Form {
                Section {
                    NavigationLink(
                        "Go to screen A",
                        state: NavigationDemo.Path.State.screenA()
                    )
                    NavigationLink(
                        "Go to screen B",
                        state: NavigationDemo.Path.State.screenB()
                    )
                    NavigationLink(
                        "Go to screen C",
                        state: NavigationDemo.Path.State.screenC()
                    )
                }
                
                Section {
                    Button("Go to A → B → C") {
                        store.send(.goToABCButtonTapped)
                    }
                }
            }
        } destination: {
            switch $0 {
            case .screenA:
                CaseLet(
                    /NavigationDemo.Path.State.screenA,
                    action: NavigationDemo.Path.Action.screenA,
                    then: ScreenAView.init(store:)
                )
            case .screenB:
                CaseLet(
                    /NavigationDemo.Path.State.screenB,
                    action: NavigationDemo.Path.Action.screenB,
                    then: ScreenBView.init(store:)
                )
            case .screenC:
                CaseLet(
                    /NavigationDemo.Path.State.screenC,
                    action: NavigationDemo.Path.Action.screenC,
                    then: ScreenCView.init(store:)
                )
            }
        }
        .navigationTitle("Navigation Stack")
    }
}

// MARK: - Screen A

struct ScreenA: Reducer {
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
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
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
                        Text("\(viewStore.count)")
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
                    NavigationLink(
                        "Go to screen C",
                        state: NavigationDemo.Path.State.screenC(
                            .init(count: viewStore.count)
                        )
                    )
                }
            }
            .buttonStyle(.borderless)
        }
        .navigationTitle("Screen A")
    }
}

// MARK: - Screen B

struct ScreenB: Reducer {
    struct State :Equatable { }
    
    enum Action {
        case screenAButtonTapped
        case screenBButtonTapped
        case screenCButtonTapped
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
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

struct ScreenC: Reducer {
    struct State: Equatable {
        var count = 0
        var isTimerRunning = false
    }
    
    enum Action: Equatable {
        case startButtonTapped
        case stopButtonTapped
        case timerTick
    }
    
    @Dependency(\.mainQueue) var mainQueue
    enum CancelID { case timer }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .startButtonTapped:
            state.isTimerRunning = true
            return .run { send in
                for await _ in self.mainQueue.timer(interval: 1) {
                    await send(.timerTick)
                }
            }
            .cancellable(id: CancelID.timer)
            .concatenate(with: .send(.stopButtonTapped))
            
        case .stopButtonTapped:
            state.isTimerRunning = false
            return .cancel(id: CancelID.timer)
            
        case .timerTick:
            state.count += 1
            return .none
        }
    }
}

struct ScreenCView: View {
    let store: StoreOf<ScreenC>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    Text("\(viewStore.count)")
                    
                    if viewStore.isTimerRunning {
                        Button("Stop timer") {
                            viewStore.send(.stopButtonTapped)
                        }
                    } else {
                        Button("Start timer") {
                            viewStore.send(.startButtonTapped)
                        }
                    }
                }
                
                Section {
                    NavigationLink(
                        "Go to screen A",
                        state: NavigationDemo.Path.State.screenA(.init(count: viewStore.count))
                    )
                    
                    NavigationLink(
                        "Go to screen B",
                        state: NavigationDemo.Path.State.screenB()
                    )
                    
                    NavigationLink("Go to screen C", state: NavigationDemo.Path.State.screenC()
                    )
                }
            }
        }
        .navigationTitle("Screen C")
    }
}
