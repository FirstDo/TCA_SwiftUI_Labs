import SwiftUI
import ComposableArchitecture

struct Timers: ReducerProtocol {
    struct State:Equatable {
        var isTimerActive = false
        var secondsElapsed = 0
    }
    
    enum Action {
        case onDisappear
        case timerTicked
        case toggleTimerButtonTapped
    }
    
    @Dependency(\.continuousClock) var clock
    enum CancelID { case timer }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onDisappear:
            return .cancel(id: CancelID.timer)
            
        case .timerTicked:
            state.secondsElapsed += 1
            return .none
            
        case .toggleTimerButtonTapped:
            state.isTimerActive.toggle()
            return .run { [isTimerActive = state.isTimerActive] send in
                guard isTimerActive else { return }
                for await _ in clock.timer(interval: .seconds(1)) {
                    await send(.timerTicked, animation: .interpolatingSpring(stiffness: 3000, damping: 40))
                }
            }
            .cancellable(id: CancelID.timer, cancelInFlight: true)
        }
    }
}

struct TimerView: View {
    let store: StoreOf<Timers>
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(store: Store(initialState: Timers.State(), reducer: Timers()))
    }
}
