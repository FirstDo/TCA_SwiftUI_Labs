import SwiftUI
import ComposableArchitecture

struct SharedState: Reducer {
    enum Tab { case counter, profile }
    
    struct State: Equatable {
        var counter = Counter.State()
        var currentTab = Tab.counter
        
        var profile: Profile.State {
            get {
                Profile.State(
                    currentTab: self.currentTab,
                    count: self.counter.count,
                    maxCount: self.counter.maxCount,
                    minCount: self.counter.minCount,
                    numberOfCounts: self.counter.numberOfCounts
                )
            }
            set {
                self.currentTab = newValue.currentTab
                self.counter.count = newValue.count
                self.counter.maxCount = newValue.maxCount
                self.counter.minCount = newValue.minCount
                self.counter.numberOfCounts = newValue.numberOfCounts
            }
        }
    }
    
    enum Action {
        case counter(Counter.Action)
        case profile(Profile.Action)
        case selectTab(Tab)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.counter, action: /Action.counter) {
            Counter()
        }
        Scope(state: \.profile, action: /Action.profile) {
            Profile()
        }
        Reduce { state, action in
            switch action {
            case .counter, .profile:
                return .none
            case let .selectTab(tab):
                state.currentTab = tab
                return .none
            }
        }
    }
    
    struct Counter: Reducer {
        struct State: Equatable {
            var alert: AlertState<Action>?
            var count = 0
            var maxCount = 0
            var minCount = 0
            var numberOfCounts = 0
        }
        
        enum Action: Equatable {
            case alertDismissed
            case decrementButtonTapped
            case incrementButtonTapped
            case isPrimeButtonTapped
        }
        
        func reduce(into state: inout State, action: Action) -> Effect<Action> {
            switch action {
            case .alertDismissed:
                state.alert = nil
                return .none
                
            case .decrementButtonTapped:
                state.count -= 1
                state.numberOfCounts += 1
                state.minCount = min(state.minCount, state.count)
                return .none
                
            case .incrementButtonTapped:
                state.count += 1
                state.numberOfCounts += 1
                state.maxCount = max(state.maxCount, state.count)
                return .none
                
            case .isPrimeButtonTapped:
                state.alert = AlertState {
                    TextState(
                        isPrime(state.count)
                        ? "👍 The number \(state.count) is prime!"
                        : "👎 The number \(state.count) is not prime :("
                    )
                }
                return .none
            }
        }
    }
    struct Profile: Reducer {
        struct State: Equatable {
            private(set) var currentTab: Tab
            private(set) var count = 0
            private(set) var maxCount: Int
            private(set) var minCount: Int
            private(set) var numberOfCounts: Int
            
            fileprivate mutating func resetCount() {
                self.currentTab = .counter
                self.count = 0
                self.maxCount = 0
                self.minCount = 0
                self.numberOfCounts = 0
            }
        }
        
        enum Action: Equatable {
            case resetCounterButtonTapped
        }
        
        func reduce(into state: inout State, action: Action) -> Effect<Action> {
            switch action {
            case .resetCounterButtonTapped:
                state.resetCount()
                return .none
            }
        }
    }
}

struct SharedStateView: View {
    let store: StoreOf<SharedState>
    var body: some View {
        WithViewStore(self.store, observe: \.currentTab) { viewStore in
            VStack {
                Picker(
                    "Tab",
                    selection: viewStore.binding(send: SharedState.Action.selectTab)) {
                        Text("Counter")
                            .tag(SharedState.Tab.counter)
                        
                        Text("Counter")
                            .tag(SharedState.Tab.profile)
                    }
                    .pickerStyle(.segmented)
                
                if viewStore.state == .counter {
                    SharedStateCounterView(store: store.scope(state: \.counter, action: SharedState.Action.counter))
                }
                
                if viewStore.state == .profile {
                    SharedStateProfileView(store: store.scope(state: \.profile, action: SharedState.Action.profile))
                }
                
                Spacer()
            }
        }
        .padding()
    }
}

struct SharedStateCounterView: View {
    let store: StoreOf<SharedState.Counter>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                HStack {
                    Button {
                        viewStore.send(.decrementButtonTapped)
                    } label: {
                        Image(systemName: "minus")
                    }

                    Text("\(viewStore.count)")
                        .monospacedDigit()
                    
                    Button {
                        viewStore.send(.incrementButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                Button("Is this prime?") {
                    viewStore.send(.isPrimeButtonTapped)
                }
            }
            .padding(.top)
            .navigationTitle("Shared State Demo")
//            .alert(store.scope(state: \.alert, action: { $0 }), dismiss: .alertDismissed)
        }
    }
}

struct SharedStateProfileView: View {
    let store: StoreOf<SharedState.Profile>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                Text("Current count: \(viewStore.count)")
                Text("Max count: \(viewStore.maxCount)")
                Text("Min count: \(viewStore.minCount)")
                Text("Total number of count events: \(viewStore.numberOfCounts)")
                Button("Reset") { viewStore.send(.resetCounterButtonTapped) }
            }
            .padding(.top)
            .navigationTitle("Profile")
        }
    }
}

private func isPrime(_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrtf(Float(p))) {
        if p % i == 0 { return false }
    }
    return true
}
