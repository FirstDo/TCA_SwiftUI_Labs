import ComposableArchitecture

struct Screen: Reducer {
    enum State: Equatable {
        case main(MainFeature.State)
        case detail(DetailFeature.State)
    }
    
    enum Action: Equatable {
        case main(MainFeature.Action)
        case detail(DetailFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.main, action: /Action.main) {
            MainFeature()
        }
        Scope(state: /State.detail, action: /Action.detail) {
            DetailFeature()
        }
    }
}
