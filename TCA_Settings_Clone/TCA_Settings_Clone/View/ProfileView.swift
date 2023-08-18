import SwiftUI
import ComposableArchitecture

struct ProfileFeature: Reducer {
    struct State: Equatable {
        let title = "김도연"
        let imageName = "dudu"
        let description = "Apple ID, iCloud, 미디어 및 구입 항목"
    }
    
    enum Action: Equatable {
        case tapped
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .tapped:
            return .none
        }
    }
}

struct ProfileView: View {
    let store: StoreOf<ProfileFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Image("dudu")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.vertical, 5)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(viewStore.title)
                        .font(.title)
                    Text(viewStore.description)
                        .font(.caption2)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(store: .init(initialState: .init()) {
            ProfileFeature()
        })
        .previewLayout(.sizeThatFits)
    }
}
