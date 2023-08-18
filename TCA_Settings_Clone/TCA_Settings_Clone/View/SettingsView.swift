import SwiftUI
import ComposableArchitecture

struct SettingsFeature: Reducer {
    struct State: Equatable {
        var section1 = IdentifiedArray(uniqueElements: Cell.first)
        var section2 = IdentifiedArray(uniqueElements: Cell.second)
        var section3 = IdentifiedArray(uniqueElements: Cell.third)
        
        var path = StackState<DetailFeature.State>()
        @PresentationState var alert: AlertState<Action.Alert>?
        var toggleState = RowWithToggleFeature.State(type: .airplaneMode, toggle: true)
    }
    
    enum Action: Equatable {
        case path(StackAction<DetailFeature.State, DetailFeature.Action>)
        case alert(PresentationAction<Alert>)
        case subAction(RowWithToggleFeature.Action)
        
        enum Alert: Equatable {
            case confirm
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .subAction:
                state.alert = AlertState {
                    TextState("스위치를 토글할까요?")
                } actions: {
                    ButtonState(role: .destructive, action: .confirm) {
                        TextState("Toggle")
                    }
                }
                return .none
                
            case .alert(.presented(.confirm)):
                state.toggleState.toggle.toggle()
                return .none
                
            case .alert:
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            DetailFeature()
                ._printChanges()
        }
        .ifLet(\.$alert, action: /Action.alert)
        
        Scope(state: \.toggleState, action: /Action.subAction) {
            RowWithToggleFeature()
                ._printChanges()
        }
    }
}

struct SettingsView: View {
    let store: StoreOf<SettingsFeature>
    
    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: { .path($0)} )) {
            WithViewStore(store, observe: { $0 }) { viewStore in
                Form {
                    Section {
                        NavigationLink(state: DetailFeature.State(title: "프로필 수정")) {
                            ProfileView(store: .init(initialState: .init()) {
                                ProfileFeature()
                            })
                        }
                    }
                    
                    Section {
                        ForEach(viewStore.section1) { cell in
                            NavigationLink(state: DetailFeature.State(title: cell.rawValue)) {
                                Row(type: cell)
                            }
                        }
                    }
                    
                    Section {
                        ForEach(viewStore.section2) { cell in
                            if cell == .airplaneMode {
                                RowWithToggle(store: store.scope(state: \.toggleState, action: SettingsFeature.Action.subAction))
                            } else {
                                NavigationLink(state: DetailFeature.State(title: cell.rawValue)) {
                                    Row(type: cell)
                                }
                            }
                        }
                    }
                    
                    Section {
                        ForEach(viewStore.section3) { cell in
                            NavigationLink(state: DetailFeature.State(title: cell.rawValue)) {
                                Row(type: cell)
                            }
                        }
                    }
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.large)
            .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
        } destination: { subStore in
            DetailView(store: subStore)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: .init(initialState: .init()) {
            SettingsFeature()
        })
    }
}
