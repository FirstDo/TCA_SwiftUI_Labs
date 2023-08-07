import SwiftUI
import ComposableArchitecture

struct Episodes: ReducerProtocol {
    struct State: Equatable {
        var episodes: IdentifiedArrayOf<Favoriting<UUID>.State> = .mocks
    }
    
    enum Action: Equatable {
        case episode(id: UUID, action: Favoriting<UUID>.Action)
    }
    
    let favorite: @Sendable (UUID, Bool) async throws -> Bool
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
        .forEach(\.episodes, action: /Action.episode) {
            Favoriting(favorite: self.favorite)
        }
    }
}

struct EpisodesView: View {
    let store: StoreOf<Episodes>
    var body: some View {
        Form {
            ForEachStore(
                store.scope(state: \.episodes, action: Episodes.Action.episode(id:action:))
            ) { rowStore in
                FavoriteButton(store: rowStore)
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle("Favoriting")
    }
}

struct EpisodesView_Previews: PreviewProvider {
    static var previews: some View {
        EpisodesView(store: .init(
            initialState: .init(),
            reducer: Episodes(favorite: favorite(id:isFavorite:))
        ))
    }
}

struct Favoriting<ID: Hashable & Sendable>: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var alert: AlertState<Action>?
        let id: ID
        var isFavorite: Bool
        var title: String
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
            HStack(alignment: .firstTextBaseline) {
                Text(viewStore.title)
                
                Spacer()
                
                Button {
                    viewStore.send(.buttonTapped)
                } label: {
                    Image(systemName: "heart")
                        .symbolVariant(viewStore.isFavorite ? .fill : .none)
                }
            }
            .alert(store.scope(state: \.alert, action: { $0 }), dismiss: .alertDismissed)
        }
    }
}

extension IdentifiedArray where ID == UUID, Element == Favoriting<UUID>.State {
    static let mocks: Self = [
        Favoriting.State(id: UUID(), isFavorite: false, title: "Functions"),
        Favoriting.State(id: UUID(), isFavorite: false, title: "Side Effects"),
        Favoriting.State(id: UUID(), isFavorite: false, title: "Algebraic Data Types"),
        Favoriting.State(id: UUID(), isFavorite: false, title: "DSLs"),
        Favoriting.State(id: UUID(), isFavorite: false, title: "Parsers"),
        Favoriting.State(id: UUID(), isFavorite: false, title: "Composable Architecture"),
    ]
}

@Sendable func favorite<ID>(id: ID, isFavorite: Bool) async throws -> Bool {
    try await Task.sleep(nanoseconds: NSEC_PER_SEC)
    if .random(in: 0...1) > 0.25 {
        return isFavorite
    } else {
        throw FavoriteError()
    }
}

struct FavoriteError: LocalizedError, Equatable {
  var errorDescription: String? {
    "Favoriting failed."
  }
}
