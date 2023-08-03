import SwiftUI
import ComposableArchitecture

struct LoadThenNavigateList: ReducerProtocol {
    struct State: Equatable {
        
        var rows: IdentifiedArrayOf<Row> = [
            Row(id: UUID(), count: 1),
            Row(id: UUID(), count: 42),
            Row(id: UUID(), count: 100)
        ]
        
        var selection: Identified<Row.ID, Counter.State>?
        
        struct Row: Equatable, Identifiable {
            let id: UUID
            var count: Int
            var isActivityIndicatorVisible = false
        }
    }
    
    enum Action {
        case counter(Counter.Action)
        case onDisappear
        case setNavigation(selection: UUID?)
        case setNavigationSelectionDelayCompleted(UUID)
    }
    
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case load }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .counter:
                return .none
                
            case .onDisappear:
                return .cancel(id: CancelID.load)
                
            case let .setNavigation(selection: .some(navigationID)):
                for row in state.rows {
                    state.rows[id: row.id]?.isActivityIndicatorVisible =
                        row.id == navigationID
                }
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    await send(.setNavigationSelectionDelayCompleted(navigationID))
                }
                .cancellable(id: CancelID.load, cancelInFlight: true)
                
            case .setNavigation(selection: .none):
                if let selection = state.selection {
                    state.rows[id: selection.id]?.count = selection.count
                }
                state.selection = nil
                return .cancel(id: CancelID.load)
                
            case let .setNavigationSelectionDelayCompleted(id):
                state.rows[id: id]?.isActivityIndicatorVisible = false
                state.selection = Identified(
                    Counter.State(count: state.rows[id: id]?.count ?? 0),
                    id: id
                )
                return .none
            }
        }
        .ifLet(\.selection, action: /Action.counter) {
            Scope(state: \.value, action: /.self) { Counter() }
        }
    }
}

struct LoadThenNavigateListView: View {
    let store: StoreOf<LoadThenNavigateList>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
        }
    }
}

struct LoadThenNavigateListView_Previews: PreviewProvider {
    static var previews: some View {
        LoadThenNavigateListView(store: Store(
            initialState: .init(),
            reducer: LoadThenNavigateList()
        ))
    }
}
