import SwiftUI
import ComposableArchitecture

struct Focus: Reducer {
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
    
    var body: some Reducer<State, Action> {
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
                TextField("Username", text: viewStore.$username)
                    .focused($focusedField, equals: .username)
                SecureField("Password", text: viewStore.$password)
                    .focused($focusedField, equals: .password)
                Button("Sign In") {
                    viewStore.send(.signInButtonTapped)
                }
                .buttonStyle(.borderedProminent)
            }
            .textFieldStyle(.roundedBorder)
            .synchronize(viewStore.$focusedField, self.$focusedField)
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
