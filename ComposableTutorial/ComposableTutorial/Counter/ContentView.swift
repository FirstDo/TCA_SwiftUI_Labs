import SwiftUI
import ComposableArchitecture

struct CounterView: View {
    let store: StoreOf<CounterFeature>
    @ObservedObject var viewStore: ViewStoreOf<CounterFeature>
    
    init(store: StoreOf<CounterFeature>) {
        self.store = store
        self.viewStore = ViewStore(self.store, observe: { $0 })
    }
    var body: some View {
        VStack {
            Text("\(viewStore.count)")
                .roundBackground()
            
            HStack {
                Button("-") {
                    store.send(.decrementButtonTapped)
                }
                
                .roundBackground()
                Button("+") {
                    store.send(.incrementButtonTapped)
                }
                .roundBackground()
            }
            Button(viewStore.isTimerRunning ? "Stop timer": "Start Timer") {
                store.send(.toggleTimerButtonTapped)
            }
            .roundBackground()
            
            Button("Fact") {
                store.send(.factButtonTapped)
            }
            
            if viewStore.isLoading {
                ProgressView()
            } else if let fact = viewStore.fact {
                Text(fact)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

fileprivate extension View {
    func roundBackground() -> some View {
        self
            .font(.largeTitle)
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(
            store: .init(initialState: .init()) {
                CounterFeature()
            }
        )
    }
}
