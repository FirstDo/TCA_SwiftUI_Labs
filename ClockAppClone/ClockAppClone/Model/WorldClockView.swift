import SwiftUI
import ComposableArchitecture

struct WorldClockCore: Reducer {
  struct State: Equatable {
    var items: [WorldClockItem] = [.서울]
    @PresentationState var selectCountryState: WorldClockSelectCore.State?
  }
  
  enum Action: Equatable {
    case deleteItem(target: IndexSet)
    case moveItem(from: IndexSet, to: Int)
    case plusTapped
    case selectAction(PresentationAction<WorldClockSelectCore.Action>)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .deleteItem(indices):
        state.items.remove(atOffsets: indices)
      case let .moveItem(from, to):
        state.items.move(fromOffsets: from, toOffset: to)
      case .plusTapped:
        let items = Array(Set(WorldClockItem.allCases).subtracting(state.items))
          .sorted { $0.countryName < $1.countryName }
        state.selectCountryState = .init(items: items)
      case let .selectAction(.presented(.delegate(.addCity(item)))):
        state.items.append(item)
        return .none
        
      default:
        break
      }
      return .none
    }
    .ifLet(\.$selectCountryState, action: /Action.selectAction) {
      WorldClockSelectCore()
    }
  }
}

struct WorldClockView: View {
  let store: StoreOf<WorldClockCore>
  @ObservedObject var viewStore: ViewStoreOf<WorldClockCore>
  @State var mode: EditMode = .inactive
  
  init() {
    self.store = Store(initialState: .init()) { WorldClockCore() }
    self.viewStore = ViewStore(store, observe: { $0 })
  }
  
  var body: some View {
    ZStack {
      Color.black
      
      List {
        ForEach(viewStore.items) { item in
          WorldClockRow(item: item, isEdit: mode == .active)
            .frame(height: 80)
        }
        .onMove { (indexSet, index) in
          store.send(.moveItem(from: indexSet, to: index))
        }
        .onDelete { indexSet in
          store.send(.deleteItem(target: indexSet))
        }
        .listRowSeparatorTint(.gray.opacity(0.7))
      }
      .listStyle(.inset)
    }
    .sheet(store: store.scope(state: \.$selectCountryState, action: { .selectAction($0) })) { subStore in
      WorldClockSelectView(store: subStore)
    }
    .navigationTitle("세계 시계")
    .navigationBarTitleDisplayMode(.large)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        EditButton()
          .foregroundColor(.orange)
      }
      
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink(">>") {
          Color.primary
            .ignoresSafeArea()
            .toolbar(.hidden, for: .tabBar)
        }
        .tint(.orange)
      }
      
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          store.send(.plusTapped)
        } label: {
          Image(systemName: "plus")
            .foregroundColor(.orange)
        }
      }
    }
    .environment(\.editMode, $mode)
  }
}

struct WorldClockView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      WorldClockView()
        .preferredColorScheme(.dark)
    }
  }
}
