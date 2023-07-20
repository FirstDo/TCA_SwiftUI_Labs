import SwiftUI
import ComposableArchitecture

struct AlertAndConfirmationDialog: ReducerProtocol {
    struct State: Equatable {
        var alert: AlertState<Action>?
        var confirmationDialog: ConfirmationDialogState<Action>?
        var count = 0
    }
    
    enum Action: Equatable {
        case alertButtonTapped
        case alertDismissed
        case confirmationDialogButtonTapped
        case confirmationDialogDismissed
        case decrementButtonTapped
        case incrementButtonTapped
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .alertButtonTapped:
            state.alert = AlertState(title: {
                TextState("Alert!")
            }, actions: {
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
            }, message: {
                TextState("This is an alert")
            })
            return .none
            
        case .alertDismissed:
            state.alert = nil
            return .none
            
        case .confirmationDialogButtonTapped:
            state.confirmationDialog = ConfirmationDialogState {
                TextState("Confirmation dialog")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
                ButtonState(action: .incrementButtonTapped) {
                    TextState("Increment")
                }
                ButtonState(action: .decrementButtonTapped) {
                    TextState("Decrement")
                }
            } message: {
                TextState("This is a confirmation dialog.")
            }
            return .none
            
        case .confirmationDialogDismissed:
            state.confirmationDialog = nil
            return .none
            
        case .decrementButtonTapped:
            state.alert = AlertState { TextState("Decremented!") }
            state.count -= 1
            return .none
            
        case .incrementButtonTapped:
            state.alert = AlertState { TextState("Incremented!") }
            state.count += 1
            return .none
        }
    }
}

struct AlertAndConfirmationDialogView: View {
    let store: StoreOf<AlertAndConfirmationDialog>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Text("Count: \(viewStore.count)")
            Button("Alert") {
                viewStore.send(.alertButtonTapped)
            }
            Button("Confirmation Dialog") {
                viewStore.send(.confirmationDialogButtonTapped)
            }
        }
        .navigationTitle("Alerts & Dialogs")
        .alert(self.store.scope(state: \.alert, action: { $0 }), dismiss: .alertDismissed)
        .confirmationDialog(self.store.scope(state: \.confirmationDialog, action: { $0 }), dismiss: .confirmationDialogDismissed)
    }
}

struct AlertAndConfirmationDialogView_Previews: PreviewProvider {
    static var previews: some View {
        AlertAndConfirmationDialogView(store: Store(
            initialState: AlertAndConfirmationDialog.State(),
            reducer: AlertAndConfirmationDialog()
        ))
    }
}
