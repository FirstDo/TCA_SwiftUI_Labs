import SwiftUI
import ComposableArchitecture

struct RowWithToggleFeature: Reducer {
    struct State: Equatable {
        let type: Cell
        var toggle: Bool
    }
    
    enum Action: Equatable {
        case toggle
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .toggle:
            return .none
        }
    }
}

struct RowWithToggle: View {
    let store: StoreOf<RowWithToggleFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: 20) {
                Image(systemName: viewStore.type.imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 7).fill(viewStore.type.tintColor))
                Text(viewStore.type.rawValue)

                Spacer()

                Toggle("", isOn: viewStore.binding(get: \.toggle, send: .toggle))
            }
        }
    }
}
