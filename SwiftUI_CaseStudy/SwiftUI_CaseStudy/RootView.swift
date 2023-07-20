import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<Root>
    
    var body: some View {
        NavigationView {
            Form {
                Section("Getting started") {
                    NavigationLink("Basics") {
                        CounterView(store: store.scope(state: \.counter, action: Root.Action.counter))
                    }
                    NavigationLink("Combining reducers") {
                        TwoCounterView(store: store.scope(state: \.twoCounter, action: Root.Action.twoCounter))
                    }
                    NavigationLink("Bindings") {
                        BindingsView(store: store.scope(state: \.bindings, action: Root.Action.bindings))
                    }
                    NavigationLink("Form bindings") {
                        BindingsFormView(store: Store(initialState: BindingsForm.State(), reducer: BindingsForm()))
                    }
                    NavigationLink("Optional State") {
                        OptionalCounterView(store: Store(initialState: OptionalCounter.State(), reducer: OptionalCounter()))
                    }
                    NavigationLink("Shared State") {
                        SharedStateView(store: Store(initialState: SharedState.State(), reducer: SharedState()))
                    }
                    NavigationLink("Alerts and Confirmation Dialogs") {
                        AlertAndConfirmationDialogView(store: Store(
                            initialState: AlertAndConfirmationDialog.State(),
                            reducer: AlertAndConfirmationDialog()
                        ))
                    }
                    NavigationLink("Focus State") {
                        FocusStateView(store: Store(initialState: Focus.State(), reducer: Focus()))
                    }
                    NavigationLink("Animations") {
                        AnimationView(store: Store(initialState: Animations.State(), reducer: Animations()))
                    }
                }
                
                Section("Effects") {
                    NavigationLink("Basics") {
                        Effects_BasicsView(store: Store(
                            initialState: Effects_Basics.State(),
                            reducer: Effects_Basics()
                        ))
                    }
                    NavigationLink("Cancellation") {
                        EffectsCancellationView(store: Store(
                            initialState: EffectsCancellation.State(),
                            reducer: EffectsCancellation()
                        ))
                    }
                    NavigationLink("Long-living effects") {
                        Text("Long-living effects")
                    }
                    NavigationLink("Refreshable") {
                        Text("Refreshable")
                    }
                    NavigationLink("Timers") {
                        Text("Timers")
                    }
                    NavigationLink("Web socket") {
                        Text("Web socket")
                    }
                }
            }
            .navigationTitle("Case Studies")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(store: Store(
            initialState: Root.State(),
            reducer: Root()
        ))
    }
}

