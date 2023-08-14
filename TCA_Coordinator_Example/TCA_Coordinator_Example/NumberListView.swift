import SwiftUI
import ComposableArchitecture

struct NumberList: Reducer {
    struct State: Equatable {
        var numbers: [Int]
    }
    enum Action: Equatable {
        case numberSelected(Int)
    }
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        return .none
    }
}

struct NumberListView: View {
    let store: StoreOf<NumberList>
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
