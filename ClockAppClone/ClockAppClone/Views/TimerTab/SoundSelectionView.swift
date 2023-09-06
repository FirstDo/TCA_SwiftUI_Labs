import SwiftUI
import ComposableArchitecture

struct SoundSelectionCore: Reducer {
  struct State: Equatable {
    
  }
  
  enum Action: Equatable {
    
  }
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    default: return .none
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
    self.store = Store(initialState: .init()) { SoundSelectionCore() }
    self.viewStore = ViewStore(self.store, observe: { $0 })
  }
  
  var body: some View {
    NavigationStack {
      List {
        
      }
    }
  }
}

struct SoundSelectionView_Previews: PreviewProvider {
  static var previews: some View {
    SoundSelectionView(store: .init(initialState: SoundSelectionCore.State()) {
      SoundSelectionCore()
    })
  }
}
