import SwiftUI
import ComposableArchitecture

struct RowFeature: Reducer {
    struct State: Equatable {
        let type: Cell
    }
    
    enum Action {
        case tapped
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .tapped:
            return .none
        }
    }
}

struct Row: View {
    let store: StoreOf<RowFeature>
    var body: some View {
        WithViewStore(store, observe: \.type) { type in
            HStack {
                Image(systemName: type.imageName)
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 7).fill(type.tintColor))
                Text(type.rawValue)
                
                Spacer()
                
                switch type.style {
                case .normal:
                    Text("")
                case .toggle:
                    Toggle("", isOn: .constant(true))
                case let .detail(description):
                    Text(description)
                }
            }
        }
    }
}

struct Row_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Row(store: .init(initialState: .init(type: .airplaneMode)) { RowFeature() })
            Row(store: .init(initialState: .init(type: .cellular)) { RowFeature() })
            Row(store: .init(initialState: .init(type: .hotsopt)) { RowFeature() })
        }
        .previewLayout(.sizeThatFits)
    }
}
