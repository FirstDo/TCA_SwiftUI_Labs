import SwiftUI
import ComposableArchitecture

struct SoundSelectionCore: Reducer {
  struct State: Equatable {
    var selectedRing: String
    let rings = ["전파 탐지기", "공상음", "공지음", "녹차", "놀이 시간", "느린 상승"]
  }
  
  enum Action: Equatable {
    case cancel
    case set
    case select(String)
    case delegate(Delegate)
    
    enum Delegate: Equatable {
      case changeSound(String)
    }
  }
  
  @Dependency(\.dismiss) var dismiss
  
  let audioPlayer = AudioService()
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .delegate:
      return .none
      
    case .cancel, .set:
      return .run { [state] send in
        await send(.delegate(.changeSound(state.selectedRing)))
        await dismiss()
      }
      
    case let .select(ring):
      state.selectedRing = ring
      audioPlayer.play()
      return .none
    }
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      return .none
    }
  }
}

struct SoundSelectionView: View {
  let store: StoreOf<SoundSelectionCore>
  @ObservedObject var viewStore: ViewStoreOf<SoundSelectionCore>
  
  init(store: StoreOf<SoundSelectionCore>) {
    self.store = store
    self.viewStore = ViewStore(self.store, observe: { $0 })
  }
  
  var body: some View {
    NavigationStack {
      RingList
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("취소") {
              store.send(.cancel)
            }
            .tint(.orange)
          }
          
          ToolbarItem(placement: .principal) {
            Text("타이머 종료시")
              .bold()
              .foregroundColor(.white)
          }
          
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("설정") {
              store.send(.set)
            }
            .tint(.orange)
          }
        }
    }
  }
}

extension SoundSelectionView {
  private var RingList: some View {
    List {
      ForEach(viewStore.rings, id: \.self) { ring in
        HStack {
          Image(systemName: "checkmark")
            .foregroundColor(.orange)
            .opacity(viewStore.selectedRing == ring ? 1 : 0)
          
          Text(ring)
          
          Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
          store.send(.select(ring))
        }
      }
    }
  }
}

struct SoundSelectionView_Previews: PreviewProvider {
  static var previews: some View {
    SoundSelectionView(store: .init(initialState: SoundSelectionCore.State(selectedRing: "전파 탐지기")) {
      SoundSelectionCore()
    })
  }
}
