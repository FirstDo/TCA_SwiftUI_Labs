import SwiftUI

import SwiftUI
import ComposableArchitecture

private extension Double {
  var minuteAndSecond: String {
    let minute = String(format: "%02d", Int(self / 60))
    let second = String(format: "%05.2f", self.truncatingRemainder(dividingBy: 60))
    
    return minute + ":" + second
  }
}

struct StopWatchCore: Reducer {
  struct State: Equatable {
    var isTimmerRunning = false
    var time: Double = 0
    
    
    var labs: [Double] = []
    
    var minute: Int { Int(time / 60) }
    var seconds: String { String(format: "%05.2f", time.truncatingRemainder(dividingBy: 60)) }
  }
  
  enum Action: Equatable {
    case toggleTimer
    case resetTimer
    case recordLabs
    case timerTick
  }
  
  @Dependency(\.continuousClock) var clock
  
  enum CancelID {
    case timer
  }
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .toggleTimer:
      state.isTimmerRunning.toggle()
      
      if state.isTimmerRunning {
        if state.labs.isEmpty {
          state.labs.insert(state.time, at: 0)
        }
        
        return .run { send in
          for await _ in clock.timer(interval: .milliseconds(10)) {
            await send(.timerTick)
          }
        }
        .cancellable(id: CancelID.timer)
      } else {
        return .cancel(id: CancelID.timer)
      }
    case .resetTimer:
      state.isTimmerRunning = false
      state.labs = []
      state.time = 0
      return .cancel(id: CancelID.timer)
      
    case .recordLabs:
      guard let previousLab = state.labs.first else { return .none }
      
      state.labs.insert(state.time, at: 0)
      return .none
      
    case .timerTick:
      state.time += 0.01
      return .none
      
    default:
      return .none
    }
  }
}

struct StopWatchView: View {
  let store: StoreOf<StopWatchCore>
  @ObservedObject var viewStore: ViewStoreOf<StopWatchCore>
  
  init() {
    self.store = Store(initialState: .init()) { StopWatchCore() }
    self.viewStore = ViewStore(self.store, observe: { $0 })
  }
  
  var body: some View {
    VStack {
      ZStack(alignment: .bottom) {
        TabView {
          numberTimer
          graphicsTimer
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        
        buttons
      }
      
      List {
        ForEach(Array(viewStore.labs.enumerated()), id: \.element) { (index, value) in
          if index == 0 {
            HStack {
              Text("랩 \(viewStore.labs.count - index)")
              Spacer()

              Text((viewStore.time - value).minuteAndSecond)
                .monospacedDigit()
            }
          } else {
            HStack {
              Text("랩 \(viewStore.labs.count - index)")
              
              Spacer()
              
              Text((viewStore.labs[index - 1] - value).minuteAndSecond)
                .monospacedDigit()
            }
          }
        }
      }
      .listStyle(.plain)
    }
  }
  
  var numberTimer: some View {
    Text(viewStore.time.minuteAndSecond)
      .font(.system(size: 70, weight: .light))
      .monospacedDigit()
  }
  var graphicsTimer: some View {
    Text(viewStore.time.minuteAndSecond)
      .font(.system(size: 70, weight: .light))
      .monospacedDigit()
  }
  
  var buttons: some View {
    HStack {
      if viewStore.isTimmerRunning {
        ClockButton(title: "랩", color: .gray) {
          store.send(.recordLabs)
        }
        .frame(width: 80)
      } else {
        ClockButton(title: "재설정", color: .gray) {
          store.send(.resetTimer)
        }
        .frame(width: 80)
      }
      
      Spacer()
      
      ClockButton(
        title: viewStore.isTimmerRunning ? "중단" : "시작",
        color: viewStore.isTimmerRunning ? .red : .green
      ) {
        store.send(.toggleTimer)
      }
      .frame(width: 80)

    }
    .padding(.horizontal)
  }
}

struct StopWatchView_Previews: PreviewProvider {
  static var previews: some View {
    StopWatchView()
      .preferredColorScheme(.dark)
  }
}
