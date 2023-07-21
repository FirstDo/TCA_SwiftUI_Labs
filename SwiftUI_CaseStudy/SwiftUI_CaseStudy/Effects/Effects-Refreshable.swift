import SwiftUI

import ComposableArchitecture

struct Refreshable: ReducerProtocol {
    struct State: Equatable {
        var count = 0
        var fact: String?
    }
    
    enum Action {
        case cancelButtonTapped
        case decrementButtonTapped
        case incrementButtonTapped
        case factResponse(TaskResult<String>)
        case refresh
    }
    
    @Dependency(\.factClient) var factClient
    enum CancelID { case factRequest }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .cancelButtonTapped:
            return .cancel(id: CancelID.factRequest)
            
        case .decrementButtonTapped:
            state.count -= 1
            return .none
            
        case .incrementButtonTapped:
            state.count += 1
            return .none
            
        case let .factResponse(.success(text)):
            state.fact = text
            return .none
            
        case .factResponse(.failure):
            return .none
            
        case .refresh:
            state.fact = nil
            return .run { [count = state.count] send in
                await send(.factResponse(
                    TaskResult { try await factClient.fetch(count) }
                ), animation: .default)
            }
            .cancellable(id: CancelID.factRequest)
        }
    }
}

struct RefreshableView: View {
    @State private var isLoading = false
    let store: StoreOf<Refreshable>
    
    var body: some View {
        WithViewStore(store, observe: {$0 }) { viewStore in
            List {
                HStack {
                    Button {
                        viewStore.send(.decrementButtonTapped)
                    } label: {
                        Image(systemName: "minus")
                    }
                    
                    Text("\(viewStore.count)")
                    
                    Button {
                        viewStore.send(.incrementButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity)
                
                if let fact = viewStore.fact {
                    Text(fact).bold()
                }
                
                if isLoading {
                    HStack {
                        Button("Cancel") {
                            viewStore.send(.cancelButtonTapped)
                        }
                        Spacer()
                    }
                }
            }
            .refreshable {
                defer { isLoading = false }
                
                self.isLoading = true
                await viewStore.send(.refresh).finish()
            }
        }
    }
}

struct RefreshableView_Preview: PreviewProvider {
    static var previews: some View {
        RefreshableView(store: Store(
            initialState: Refreshable.State(),
            reducer: Refreshable()
        ))
    }

}
