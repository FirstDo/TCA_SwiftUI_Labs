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
            LongLivingEffectsView(store: Store(
              initialState: LongLivingEffects.State(),
              reducer: LongLivingEffects()
            ))
          }
          NavigationLink("Refreshable") {
            RefreshableView(store: Store(
              initialState: Refreshable.State(),
              reducer: Refreshable()
            ))
          }
          NavigationLink("Timers") {
            TimerView(store: Store(
              initialState: Timers.State(),
              reducer: Timers()
            ))
          }
          NavigationLink("Web socket") {
            WebSocketView(store: Store(
              initialState: WebSocket.State(),
              reducer: WebSocket()
            ))
          }
        }
        
        Section("Navigation") {
          NavigationLink("Stack") {
            Text("Stack")
          }
          
          NavigationLink("Navigate and load data") {
            Text("Navigate and load data")
          }
          
          NavigationLink("Load data then navigate") {
            Text("Load data then navigate")
          }
          
          NavigationLink("Lists: Navigate and load data") {
            Text("Lists: Navigate and load data")
          }
          
          NavigationLink("Lists: Load data then navigate") {
            Text("Lists: Load data then navigate")
          }
          
          NavigationLink("Sheets: Present and load data") {
            Text("Sheets: Present and load data")
          }
          
          NavigationLink("Sheets: Load data then present") {
            Text("Sheets: Load data then present")
          }
        }
        
        Section("Higher-Order Reducers") {
          NavigationLink("Reusable favoriting component") {
            Text("Reusable favoriting component")
          }
          
          NavigationLink("Reusable offline download component") {
            Text("Reusable offline download component")
          }
          
          NavigationLink("Lifecycle") {
            Text("Lifecycle")
          }
          
          NavigationLink("Elm-like subscriptions") {
            Text("Elm-like subscriptions")
          }
          
          NavigationLink("Recursive state and actions") {
            Text("Recursive state and actions")
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

