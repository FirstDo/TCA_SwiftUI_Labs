import SwiftUI
import ComposableArchitecture

struct Home: Reducer {
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        case startTapped
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        return .none
    }
}

struct HomeView: View {
    let store: StoreOf<Home>
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
