import SwiftUI
import ComposableArchitecture

import SwiftUI
import ComposableArchitecture

struct WorldClockSelectCore: Reducer {
  struct State: Equatable {
    let sectionTitles = ["가", "나", "다", "라", "마", "바", "사", "아", "자", "차", "카", "타", "파", "하"]
    let items: [WorldClockItem]
    var query = ""
    
    var filteredItems: [WorldClockItem] {
      if query == "" { return items }
      return items
        .filter { ($0.cityName + $0.countryName).contains(query.lowercased()) }
    }
    
    var sectionItmes: [[WorldClockItem]] {
      sectionTitles.enumerated().map { index, value in
        items.filter {
          let ch = String($0.cityName.first!)
          
          if index == sectionTitles.count - 1 {
            return ch >= value
          } else {
            return ch >= value && ch < sectionTitles[index + 1]
          }
        }
      }
    }
  }
  
  enum Action: Equatable {
    case cancelTapped
    case setQuery(String)
    case cellTapped(WorldClockItem)
    case delegate(Delegate)
    
    enum Delegate: Equatable {
      case addCity(WorldClockItem)
    }
  }
  
  @Dependency(\.dismiss) var dismiss
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .cancelTapped:
        return .run { send in
          await dismiss()
        }
        
      case let .setQuery(text):
        state.query = text
        return .none
        
      case let .cellTapped(item):
        return .run { send in
          await send(.delegate(.addCity(item)))
          await dismiss()
        }
        
      case .delegate:
        return .none
      }
    }
  }
}

struct WorldClockSelectView: View {
  let store: StoreOf<WorldClockSelectCore>
  @ObservedObject var viewStore: ViewStoreOf<WorldClockSelectCore>
  
  init(store: StoreOf<WorldClockSelectCore>) {
    self.store = store
    self.viewStore = ViewStore(self.store, observe: { $0 })
  }

  var body: some View {
    VStack {
      Text("도시 선택").padding(.vertical, 10)
      HStack {
        SearchView(text: viewStore.binding(get: \.query, send: { .setQuery($0)} ))
        Button("취소") {
          viewStore.send(.cancelTapped)
        }
      }
      .padding(.horizontal)
      list
    }
  }
  
  var list: some View {
    List {
      if viewStore.query.isEmpty {
        ForEach(Array(zip(viewStore.sectionTitles, viewStore.sectionItmes)), id: \.0) { (title, section) in
          if !section.isEmpty {
            Section(title) {
              ForEach(section) { item in
                Text(item.cityName + "," + item.countryName)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .contentShape(Rectangle())
                  .onTapGesture {
                    viewStore.send(.cellTapped(item))
                  }
              }
            }
          }
        }
      } else {
        ForEach(viewStore.filteredItems) { item in
          Text(item.cityName + "," + item.countryName)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
              viewStore.send(.cellTapped(item))
            }
        }
      }
    }
    .listStyle(.plain)
    .searchable(text: viewStore.binding(get: \.query, send: { .setQuery($0) }))
  }
}

struct WorldClockSelectView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      WorldClockSelectView(store: .init(
        initialState: WorldClockSelectCore.State(items: [.서울])) {
          WorldClockSelectCore()
        })
    }
    .preferredColorScheme(.dark)
  }
}
