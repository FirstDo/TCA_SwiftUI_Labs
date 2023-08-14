import SwiftUI
import ComposableArchitecture

struct NumberDetail: Reducer {
    struct State: Equatable {
        var number: Int
    }
    
    enum Action: Equatable {
        case showDouble(Int)
        case goBackTapped
        case goBackToNumberList
        case goBatkToRootTapped
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        return .none
    }
}

struct NumberDetailView: View {
    let store: StoreOf<NumberDetail>
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
