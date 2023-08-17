import SwiftUI
import ComposableArchitecture

struct ContentFeature: Reducer {
    struct State: Equatable {
        var numbers: String
    }
    
    enum Action: Equatable {
        case numberTapped(String)
        case deleteTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .numberTapped(num):
                state.numbers.append(num)
                return .none
            case .deleteTapped:
                if state.numbers.isEmpty == false {
                    _ = state.numbers.removeLast()
                }
                return .none
            }
        }
    }
}

struct ContentView: View {
    let store: StoreOf<ContentFeature>
    @ObservedObject var viewStore: ViewStoreOf<ContentFeature>
    
    private let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    init(store: StoreOf<ContentFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            TopSection
                .frame(height: 100)
            
            NumberPad
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
        }
        .contentShape(Rectangle())
        .gesture(swipeDeleteGesture)
    }
}

private extension ContentView {
    var swipeDeleteGesture: some Gesture {
        return DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onEnded { value in
                if value.translation.width < 0 {
                    store.send(.deleteTapped, animation: .default)
                }
            }
    }
    
    var TopSection: some View {
        VStack(spacing: 10) {
            Text(viewStore.numbers)
                .font(.largeTitle).bold()
                .animation(.none)
            
            Menu {
                Button {
                } label: {
                    Label("새로운 연락처 등록", systemImage: "person.circle")
                }
                
                Button {
                } label: {
                    Label("기존의 연락처에 추가", systemImage: "person.crop.circle.badge.plus")
                }
            } label: {
                Text("번호 추가")
                    .frame(maxWidth: .infinity)
                    .font(.title3)
                    .opacity(viewStore.numbers.isEmpty ? 0 : 1)
            }
        }
    }
    
    var NumberPad: some View {
        LazyVGrid(columns: rows, alignment: .center, spacing: 20) {
            ForEach(Number.allCases, id: \.self) { number in
                NumberButton(number: number) {
                    store.send(.numberTapped(number.rawValue), animation: .default)
                }
            }
            
            Color.white
            NumberButton(number: nil) {}
            if viewStore.numbers.count > 0 {
                DeleteButton {
                    store.send(.deleteTapped, animation: .default)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: MyApp.store)
    }
}
