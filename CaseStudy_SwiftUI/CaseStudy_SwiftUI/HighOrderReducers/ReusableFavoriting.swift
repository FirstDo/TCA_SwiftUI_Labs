import SwiftUI
import ComposableArchitecture

struct EpisodesView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct EpisodeView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct Favoriting<ID: Hashable & Sendable>: ReducerProtocol {
    struct State: Equatable {
        var alert: AlertState<Action>?
        let id: ID
        var isFavorite: Bool
    }
    
    enum Action: Equatable {
        case alertDismissed
        case buttonTapped
        case response(TaskResult<Bool>)
    }
    
    let favorite: @Sendable (ID, Bool) async throws -> Bool
    
    private struct CancelID: Hashable {
        let id: AnyHashable
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .alertDismissed:
            state.alert = nil
            state.isFavorite.toggle()
            return .none
            
        case .buttonTapped:
            state.isFavorite.toggle()
            
            return .run { [state] send in
                await send(.response(TaskResult {
                    try await favorite(state.id, state.isFavorite)
                }))
            }
            .cancellable(id: CancelID(id: state.id), cancelInFlight: true)
            
        case let .response(.failure(error)):
            state.alert = AlertState { TextState(error.localizedDescription) }
            return .none
            
        case let .response(.success(isFavorite)):
            state.isFavorite = isFavorite
            return .none
        }
    }
    
}

struct FavoriteButton<ID: Hashable & Sendable>: View {
    let store: StoreOf<Favoriting<ID>>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.buttonTapped)
            } label: {
                Image(systemName: "heart")
                    .symbolVariant(viewStore.isFavorite ? .fill : .none)
            }
            .alert(store.scope(state: \.alert, action: { $0 }), dismiss: .alertDismissed)
        }
    }
}

struct EpisodesView_Previews: PreviewProvider {
    static var previews: some View {
        EpisodesView()
    }
}
