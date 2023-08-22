import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct MainTabCoordinator: Reducer {
    enum Tab: Hashable {
        case index, form
    }
    
    struct State: Equatable {
        static let initState = State(index: .initialState, form: .initalState, selectedTab: .index)
        
        var index: IndexCoordinator.State
        var form: FormAppCoordinator.State
        var selectedTab: Tab
    }
    
    enum Action {
        case index(IndexCoordinator.Action)
        case form(FormAppCoordinator.Action)
        case tabSelected(Tab)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.index, action: /Action.index) {
            IndexCoordinator()
        }
        
        Scope(state: \.form, action: /Action.form) {
            FormAppCoordinator()
        }
        
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            
            default:
                return .none
            }
        }
    }
}

struct MainTabCoordinatorView: View {
    let store: StoreOf<MainTabCoordinator>
    
    var body: some View {
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(get: { $0 }, send: MainTabCoordinator.Action.tabSelected)) {
                IndexCoordinatorView(store: store.scope(state: {$0.index}, action: {.index($0)}))
                    .tabItem { Label("Index", systemImage: "swift") }
                    .tag(MainTabCoordinator.Tab.index)
                
                FormAppCoordinatorView(store: store.scope(state: {$0.form}, action: {.form($0)}))
                    .tabItem { Label("Form", systemImage: "swift")}
                    .tag(MainTabCoordinator.Tab.form)
            }
        }
    }
}
