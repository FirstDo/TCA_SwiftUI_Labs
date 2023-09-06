import SwiftUI
import ComposableArchitecture

struct TimerCore: Reducer {
  
  struct State: Equatable {
    enum TimerState: Equatable {
      case running
      case pause
      case stop
    }
    
    @PresentationState var soundSelectionState: SoundSelectionCore.State?
    
    let items = [Array(0...23), Array(0...59), Array(0...59)]
    @BindingState var hourMinuteSecond: [Int] = [0, 15, 0]
    
    var timerState: TimerState = .stop
    var startTime: Int { hourMinuteSecond[0] * 3600 + hourMinuteSecond[1] * 60 + hourMinuteSecond[2] }
    var remainTime: Int
    
    var currentRing = "전파 탐지기"
    
    init() {
      self.remainTime = 15 * 60
    }
  }
  
  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case timerTick
    case toggleTimer
    case resetTimer
    case rowTapped
    case soundSelectionAction(PresentationAction<SoundSelectionCore.Action>)
  }
  
  @Dependency(\.continuousClock) var clock
  let player = AudioService()
  
  enum CancelID {
    case timer
  }

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        state.remainTime = state.startTime
        return .none
        
      case .timerTick:
        state.remainTime -= 1
        
        if state.remainTime <= 0 {
          player.play()
          return .send(.resetTimer)
        }
        
        return .none
        
      case .toggleTimer:
        player.stop()
        // 0:00:00 일때는 타이머를 동작시키지 않음
        if state.startTime == 0 { return .none }
        
        // 타이머의 상태 변경
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
            for await _ in clock.timer(interval: .seconds(1)) {
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
        state.remainTime = state.startTime
        
        return .cancel(id: CancelID.timer)
        
      case .rowTapped:
        state.soundSelectionState = .init(selectedRing: state.currentRing)
        return .none
        
      case let .soundSelectionAction(.presented(.delegate(.changeSound(sound)))):
        state.currentRing = sound
        return .none
        
      case .soundSelectionAction:
        return .none
      }
    }
    .ifLet(\.$soundSelectionState, action: /Action.soundSelectionAction) {
      SoundSelectionCore()
    }
  }
}

struct TimerView: View {
  let store: StoreOf<TimerCore>
  @ObservedObject var viewStore: ViewStoreOf<TimerCore>
  
  init(store: StoreOf<TimerCore>) {
    self.store = store
    self.viewStore = ViewStore(self.store, observe: { $0 })
  }
  
  var body: some View {
    VStack {
      PickerAndCircleView
      
      Buttons
        .offset(y: -80)
      
      AlarmPicker
      
      Spacer()
    }
    .sheet(store: store.scope(state: \.$soundSelectionState, action: TimerCore.Action.soundSelectionAction)) { subStore in
      SoundSelectionView(store: subStore)
    }
  }
}

private extension TimerView {
  @ViewBuilder
  var PickerAndCircleView: some View {
    Rectangle().fill(.clear)
      .frame(height: UIScreen.main.bounds.height / 2)
      .debug()
      .overlay {
        if viewStore.timerState == .stop {
          CustomPicker(items: viewStore.items, selections: viewStore.$hourMinuteSecond)
            .debug()
        } else {
          TimeCircularView(totalTime: viewStore.startTime, remainTime: viewStore.remainTime, endTime: 100)
            .frame(maxWidth: .infinity)
            .padding()
            .debug()
        }
      }
  }
  
  var Buttons: some View {
    HStack {
      ClockButton(title: "취소", color: viewStore.timerState == .stop ? .gray.opacity(0.2) : .gray.opacity(0.5)) {
        store.send(.resetTimer)
      }.frame(width: 80)
      
      Spacer()
      
      ClockButton(
        title: viewStore.timerState == .stop ? "시작" : viewStore.timerState == .pause ? "재개" : "일시 정지",
        color: viewStore.timerState == .running ? .orange.opacity(0.5) : .green.opacity(0.5)
      ) {
        store.send(.toggleTimer)
      }.frame(width: 80)
    }
  }
  
  var AlarmPicker: some View {
    Button {
      store.send(.rowTapped)
    } label: {
      HStack {
        Text("타이머 종료 시")
          .foregroundColor(.white)
        Spacer()
        Text(viewStore.currentRing)
          .foregroundColor(.white.opacity(0.5))
        Image(systemName: "chevron.right")
          .foregroundColor(.white.opacity(0.5))
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(Color(uiColor: .systemGray6))
      )
    }
  }
}

struct TimerView_Previews: PreviewProvider {
  static var previews: some View {
    TimerView(store: .init(initialState: TimerCore.State()) {
      TimerCore()
    })
  }
}

struct FrameDebugModifier: ViewModifier {

  let color: Color

  func body(content: Content) -> some View {
    content
    #if DEBUG
      .overlay(GeometryReader(content: overlay(for:)))
    #endif
  }

  private func overlay(for geometry: GeometryProxy) -> some View {
    ZStack(alignment: .topTrailing) {
      Rectangle()
        .strokeBorder(style: .init(lineWidth: 1, dash: [3]))
        .foregroundColor(color)

      Text("(\(Int(geometry.frame(in: .global).origin.x)), \(Int(geometry.frame(in: .global).origin.y))) \(Int(geometry.size.width))x\(Int(geometry.size.height))")
        .font(.caption2)
        .minimumScaleFactor(0.5)
        .foregroundColor(color)
        .padding(3)
        .offset(y: -20)
    }
  }
}

extension View {
  func debug(_ color: Color = .red) -> some View {
    modifier(FrameDebugModifier(color: color))
  }
}
