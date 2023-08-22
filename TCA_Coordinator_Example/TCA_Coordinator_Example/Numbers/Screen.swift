import ComposableArchitecture
import Foundation

struct Screen: Reducer {
    enum State: Equatable, Identifiable {
        case home(Home.State)
        case numbersList(NumberList.State)
        case numberDetail(NumberDetail.State)
        
        var id: UUID {
            switch self {
            case let .home(state):
                return state.id
            case let .numbersList(state):
                return state.id
            case let .numberDetail(state):
                return state.id
            }
        }
    }
    
    enum Action {
        case home(Home.Action)
        case numbersList(NumberList.Action)
        case numberDetail(NumberDetail.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.home, action: /Action.home) {
            Home()
        }
        Scope(state: /State.numbersList, action: /Action.numbersList) {
            NumberList()
        }
        Scope(state: /State.numberDetail, action: /Action.numberDetail) {
            NumberDetail()
        }
    }
}
