import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct Coordinator: Reducer {
    struct State: Equatable, IndexedRouterState {
        var routes: [Route<Screen.State>]
        
        init(routes: [Route<Screen.State>] = [.root(.list(.init(contacts: Contact.dummy)), embedInNavigationView: true)]) {
            self.routes = routes
        }
    }
    
    enum Action: IndexedRouterAction, Equatable {
        case routeAction(Int, action: Screen.Action)
        case updateRoutes([Route<Screen.State>])
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .routeAction(_, action: .list(.itemTapped(contact))):
                state.routes.push(.detail(.init(contact: contact)))
            
            case .routeAction(_, action: .list(.addButtonTapped)):
                state.routes.presentSheet(.add(.init(contact: Contact(id: UUID(), name: ""))), embedInNavigationView: true)
                
            case .routeAction(_, action: .add(.cancelButtonTapped)):
                state.routes.dismiss()
                
            case let .routeAction(_, action: .add(.saveButtonTapped(contact))):
                for (route, index) in zip(state.routes, state.routes.indices).reversed() {
                    guard case .list(var subState) = route.screen else { continue }
                    
                    subState.addContact(contact)
                    state.routes[index].screen = .list(subState)
                }
                
                return .routeWithDelaysIfUnsupported(state.routes) {
                    $0.dismiss()
                }
                
            
            case .routeAction(_, action: .detail(.deleteButtonTapped)):
                return .routeWithDelaysIfUnsupported(state.routes) {
                    $0.pop()
                }
                
            case let .updateRoutes(route):
                state.routes = route
                
            default:
                return .none
            }
            
            return .none
        }
        .forEachRoute {
            Screen()
        }
    }
}

struct CoordinatorView: View {
    let store: StoreOf<Coordinator>
    var body: some View {
        TCARouter(store) { screenStore in
            SwitchStore(screenStore) { screen in
                switch screen {
                case .list:
                    CaseLet(/Screen.State.list, action: Screen.Action.list, then: ContactsView.init)
                case .detail:
                    CaseLet(/Screen.State.detail, action: Screen.Action.detail, then: ContactDetailView.init)
                case .add:
                    CaseLet(/Screen.State.add, action: Screen.Action.add, then: AddContactView.init)
                }
            }
        }
    }
}
