import SwiftUI
import ComposableArchitecture

struct TimerCore: Reducer {
  struct State: Equatable {
    var isTimerRunning = false
    @BindingState var hour = 0
    @BindingState var minute = 15
    @BindingState var second = 0
  }
  
  enum Action: Equatable, Bind {
    case timerTick
    case toggleTimer
    case cancelTapped
    case rowTapped
  }
  
  @Dependency(\.continuousClock) var clock
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    default:
      return .none
    }
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      return .none
    }
    
  }
}

struct TimerView: View {
  let store: StoreOf<TimerCore>
  @ObservedObject var viewStore: ViewStoreOf<TimerCore>
  
  init() {
    self.store = Store(initialState: .init()) {
      TimerCore()
    }
    self.viewStore = ViewStore(self.store, observe: { $0 })
  }
  
  var body: some View {
    VStack {
      HStack {
        ClockButton(title: "취소", color: .gray) {
          
        }.frame(width: 80)
        
        Spacer()
        
        ClockButton(title: "시작", color: .green) {
          
        }.frame(width: 80)
      }
    }
  }
}

struct TimerView_Previews: PreviewProvider {
  static var previews: some View {
    TimerView()
  }
}

