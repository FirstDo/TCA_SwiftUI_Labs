import SwiftUI
import ComposableArchitecture

struct NavigateAndLoadList: ReducerProtocol {
    struct State: Equatable {
        var rows: IdentifiedArrayOf<Row> = [
            Row(id: UUID(), count: 1),
            Row(id: UUID(), count: 42),
            Row(id: UUID(), count: 100)
        ]
        var selection: Identified<Row.ID, Counter.State?>?
        
        struct Row: Equatable, Identifiable {
            let id: UUID
            var count: Int
        }
    }
    
    enum Action {
        case counter(Counter.Action)
        case setNavigation(selection: UUID?)
        case setNavigationSelectionDelayCompleted
    }
    
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case load }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .counter:
                return .none
                
            case let .setNavigation(selection: .some(id)):
                state.selection = Identified(nil, id: id)
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    await send(.setNavigationSelectionDelayCompleted)
                }
                .cancellable(id: CancelID.load, cancelInFlight: true)
                
            case .setNavigation(selection: .none):
                if let selection = state.selection,
                   let count = selection.value?.count {
                    state.rows[id: selection.id]?.count = count
                }
                state.selection = nil
                return .cancel(id: CancelID.load)
                
            case .setNavigationSelectionDelayCompleted:
                guard let id = state.selection?.id else { return .none }
                state.selection?.value = Counter.State(count: state.rows[id: id]?.count ?? 0)
                return .none
            }
        }
        .ifLet(\.selection, action: /Action.counter) {
            EmptyReducer()
                .ifLet(\.value, action: .self) { Counter() }
        }
    }
}

struct NavigateAndLoadListView: View {
    let store: StoreOf<NavigateAndLoadList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                ForEach(viewStore.rows) { row in
                    NavigationLink(
                        destination: IfLetStore(
                            self.store.scope(
                                state: \.selection?.value,
                                action: NavigateAndLoadList.Action.counter
                            )
                        ) {
                            CounterView(store: $0)
                        } else: {
                            ProgressView()
                        },
                        tag: row.id,
                        selection: viewStore.binding(
                            get: \.selection?.id,
                            send: NavigateAndLoadList.Action.setNavigation(selection:)
                        )
                    ) {
                        Text("Load optional counter that starts form \(row.count)")
                    }
                }
            }
        }
        .navigationTitle("Navigate and load")
    }
}

struct NavigateAndLoadListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigateAndLoadListView(store: .init(
            initialState: .init(),
            reducer: NavigateAndLoadList()
        ))
    }
}
