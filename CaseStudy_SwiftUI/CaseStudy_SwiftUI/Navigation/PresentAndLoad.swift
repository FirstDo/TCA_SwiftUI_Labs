import SwiftUI
import ComposableArchitecture

struct PresentAndLoad: Reducer {
    struct State: Equatable {
        var optionalCounter: Counter.State?
        var isSheetPresented = false
    }
    
    enum Action {
        case optionalCounter(Counter.Action)
        case setSheet(isPresented: Bool)
        case setSheetIsPresentedDelayCompleted
    }
    
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case load }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .optionalCounter:
                return .none
                
            case .setSheet(isPresented: true):
                state.isSheetPresented = true
                return .run { send in
                    try await clock.sleep(for: .seconds(2))
                    await send(.setSheetIsPresentedDelayCompleted)
                }.cancellable(id: CancelID.load)
                
            case .setSheet(isPresented: false):
                state.isSheetPresented = false
                state.optionalCounter = nil
                return .cancel(id: CancelID.load)
                
            case .setSheetIsPresentedDelayCompleted:
                state.optionalCounter = .init()
                return .none
            }
        }
        .ifLet(\.optionalCounter, action: /Action.optionalCounter) { Counter() }
    }
}

struct PresentAndLoadView: View {
    let store: StoreOf<PresentAndLoad>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Button("Present Optional Counter") {
                    viewStore.send(.setSheet(isPresented: true))
                }
            }
            .sheet(isPresented: viewStore.binding(
                get: \.isSheetPresented,
                send: PresentAndLoad.Action.setSheet(isPresented:)
            )) {
                IfLetStore(
                    store.scope(
                        state: \.optionalCounter,
                        action: PresentAndLoad.Action.optionalCounter
                    )
                ) {
                    CounterView(store: $0)
                } else: {
                    ProgressView()
                }
            }
            .navigationTitle("Present and load")
        }
    }
}
