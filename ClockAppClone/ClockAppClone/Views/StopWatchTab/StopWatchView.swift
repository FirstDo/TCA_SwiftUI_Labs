import SwiftUI

import SwiftUI
import ComposableArchitecture

fileprivate extension Double {
  var minuteAndSecond: String {
    let minute = String(format: "%02d", Int(self / 60))
    let second = String(format: "%05.2f", self.truncatingRemainder(dividingBy: 60))
    
    return minute + ":" + second
  }
}

struct StopWatchCore: Reducer {
  struct State: Equatable {
    enum TimerState: Equatable {
      case running
      case pause
      case stop
    }
    
    var timerState: TimerState = .stop
    var time: Double = 0
    
    var labs: [Double] = []
    var currentLabTime: Double = .zero
    
    var minute: Int { Int(time / 60) }
    var seconds: String { String(format: "%05.2f", time.truncatingRemainder(dividingBy: 60)) }
    
    
    var greenIndex: Int?
    var redIndex: Int?
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
      switch state.timerState {
      case .running:
        state.timerState = .pause
      case .pause:
        state.timerState = .running
      case .stop:
        state.timerState = .running
      }
      
      if state.timerState == .running {
        return .run { send in
          for await _ in clock.timer(interval: .seconds(0.033)) {
            await send(.timerTick)
          }
        }.cancellable(id: CancelID.timer)
      }
      
      if state.timerState == .pause {
        return .cancel(id: CancelID.timer)
      }
      
      return .none
      
    case .resetTimer:
      state.timerState = .stop
      state.labs = []
      state.currentLabTime = .zero
      state.time = 0
      
      state.greenIndex = nil
      state.redIndex = nil
      
      return .cancel(id: CancelID.timer)
      
    case .recordLabs:
      state.labs.insert(state.currentLabTime, at: 0)
      state.currentLabTime = .zero
      
      if state.labs.count >= 2 {
        let maxValue = state.labs.max()!
        let minValue = state.labs.min()!
        
        state.greenIndex = state.labs.firstIndex(of: maxValue)
        state.redIndex = state.labs.firstIndex(of: minValue)
      }
      
      return .none
      
    case .timerTick:
      state.time += 0.033
      state.currentLabTime += 0.033
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
          StopWatch
          AnalogClock
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        
        TimerButtons
      }
      .frame(height: UIScreen.main.bounds.height / 2)
      
      LabList
    }
  }
}

extension StopWatchView {
  var StopWatch: some View {
    Text(viewStore.time.minuteAndSecond)
      .font(.system(size: 70, weight: .light))
      .monospacedDigit()
  }
  
  var AnalogClock: some View {
    ZStack {
      Circle()
        .stroke(.gray, lineWidth: 4)
      
      Text(viewStore.time.minuteAndSecond)
        .font(.title2)
        .monospacedDigit()
        .offset(y: 100)
      
      GeometryReader { proxy in
        Path { path in
          path.move(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2 + 40))
          path.addLine(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2 - proxy.size.width / 2))
        }
        .stroke(.blue, lineWidth: 2)
        .rotationEffect(.degrees(viewStore.currentLabTime) * 360 / 60)
      }
      .opacity(viewStore.labs.isEmpty ? 0 : 1)
      
      GeometryReader { proxy in
        Path { path in
          path.move(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2 + 40))
          path.addLine(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2 - proxy.size.width / 2))
        }
        .stroke(.orange, lineWidth: 2)
        .rotationEffect(.degrees(viewStore.time) * 360 / 60)
      }
      .debug()
      
      Circle()
        .strokeBorder(.orange, lineWidth: 2)
        .background(Circle().foregroundColor(.black))
        .frame(width: 15)
    }
    .padding()
  }
  
  var TimerButtons: some View {
    HStack {
      switch viewStore.timerState {
      case .running:
        ClockButton(title: "랩", color: .gray.opacity(0.7)) {
          store.send(.recordLabs)
        }
        .frame(width: 80)
      case .pause:
        ClockButton(title: "재설정", color: .gray.opacity(0.7)) {
          store.send(.resetTimer)
        }
        .frame(width: 80)
      case .stop:
        ClockButton(title: "랩", color: .gray.opacity(0.3)) {

        }
        .frame(width: 80)
      }
      
      Spacer()
      
      ClockButton(
        title: viewStore.timerState == .running ? "중단" : "시작",
        color: viewStore.timerState == .running ? .red : .green
      ) {
        store.send(.toggleTimer)
      }
      .frame(width: 80)

    }
    .padding(.horizontal)
  }
  
  var LabList: some View {
    List {
      if viewStore.timerState != .stop {
        HStack {
          Text("랩 \(viewStore.labs.count + 1)")
          Spacer()
          Text(viewStore.currentLabTime.minuteAndSecond)
            .monospacedDigit()
        }
      }
      
      ForEach(Array(viewStore.labs.enumerated()), id: \.offset) { (index, value) in
        HStack {
          Text("랩 \(viewStore.labs.count - index)")
          Spacer()
          Text(value.minuteAndSecond)
            .monospacedDigit()
        }
        .foregroundColor(
          index == viewStore.redIndex ?
            .red :
            index == viewStore.greenIndex ?
              .green :
                .white
        )
      }
    }
    .listStyle(.plain)
  }
}

struct StopWatchView_Previews: PreviewProvider {
  static var previews: some View {
    StopWatchView()
      .preferredColorScheme(.dark)
  }
}
