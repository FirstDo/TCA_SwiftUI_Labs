import SwiftUI
import ComposableArchitecture

struct Focus: ReducerProtocol {
    struct State: Equatable {
        @BindingState var focusedField: Field?
        @BindingState var password: String = ""
        @BindingState var username: String = ""
        
        enum Field: String, Hashable {
            case username, password
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case signInButtonTapped
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .signInButtonTapped:
                if state.username.isEmpty {
                    state.focusedField = .username
                } else if state.password.isEmpty {
                    state.focusedField = .password
                }
                return .none
            }
        }
    }
}

struct FocusStateView: View {
    let store: StoreOf<Focus>
    @FocusState var focusedField: Focus.State.Field?
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                TextField("Username", text: viewStore.binding(\.$username))
                    .focused($focusedField, equals: .username)
                SecureField("Password", text: viewStore.binding(\.$password))
                    .focused($focusedField, equals: .password)
                Button("Sign In") {
                    viewStore.send(.signInButtonTapped)
                }
                .buttonStyle(.borderedProminent)
            }
            .textFieldStyle(.roundedBorder)
            .synchronize(viewStore.binding(\.$focusedField), self.$focusedField)
        }
        .navigationTitle("Focus demo")
    }
}

private extension View {
    func synchronize<Value>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
}

struct FocusStateView_Previews: PreviewProvider {
    static var previews: some View {
        FocusStateView(store: Store(initialState: Focus.State(), reducer: Focus()))
    }
}
