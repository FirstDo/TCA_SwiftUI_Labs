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
                        BindingsFormView(store: store.scope(state: \.bindingsForm, action: Root.Action.bindingsForm))
                    }
                    NavigationLink("Optional State") {
                        OptionalCounterView(store: store.scope(state: \.optionalCounter, action: Root.Action.optionalCounter))
                    }
                    NavigationLink("Shared State") {
                        SharedStateView(store: store.scope(state: \.sharedState, action: Root.Action.sharedState))
                    }
                    NavigationLink("Alerts and Confirmation Dialogs") {
                        AlertAndConfirmationDialogView(store: store.scope(state: \.alertAndConfirmationDialog, action: Root.Action.alert))
                    }
                    NavigationLink("Focus State") {
                        FocusStateView(store: store.scope(state: \.focus, action: Root.Action.focus))
                    }
                    NavigationLink("Animations") {
                        AnimationView(store: store.scope(state: \.animations, action: Root.Action.animation))
                    }
                }

                Section("Effects") {
                    NavigationLink("Basics!") {
                        Effects_BasicsView(store: store.scope(state: \.effectBasics, action: Root.Action.effectBasics))
                    }
                    NavigationLink("Cancellation") {
                        EffectsCancellationView(store: store.scope(state: \.effectCancellation, action: Root.Action.effectCancellaiton))
                    }
                    NavigationLink("Long-living effects") {
                        LongLivingEffectsView(store: store.scope(state: \.effectLongLiving, action: Root.Action.effectLongLiving))
                    }
                    NavigationLink("Refreshable") {
                        RefreshableView(store: store.scope(state: \.effectRefreshable, action: Root.Action.effectRefreshable))
                    }
                    NavigationLink("Timers") {
                        TimerView(store: store.scope(state: \.effectTimers, action: Root.Action.effectTimer))
                    }
                    NavigationLink("Web socket") {
                        WebSocketView(store: store.scope(state: \.effectWebSocket, action: Root.Action.effectWebSocket))
                    }
                }
              
                Section("Navigation") {
                    NavigationLink("Stack") {
                        NavigationDemoView(store: store.scope(state: \.stack, action: Root.Action.stack))
                    }
                    
                    NavigationLink("Navigate and load data") {
                        NavigateAndLoadView(store: store.scope(state: \.navigateAndLoad, action: Root.Action.naviageAndLoad))
                    }
                    
                    NavigationLink("Load data then navigate") {
                        LoadThenNavigateView(store: store.scope(state: \.loadThenNavigate, action: Root.Action.loadThenNavigate))
                    }
                    
                    NavigationLink("Lists: Navigate and load data") {
                        NavigateAndLoadListView(store: store.scope(state: \.navigateAndLoadList, action: Root.Action.navigateAndLoadList))
                    }
                    
                    NavigationLink("Lists: Load data then navigate") {
                        LoadThenNavigateListView(store: store.scope(state: \.loadThenNavigateList, action: Root.Action.loadThenNavigateList))
                    }
                    
                    NavigationLink("Sheets: Present and load data") {
                        PresentAndLoadView(store: store.scope(state: \.presentAndLoad, action: Root.Action.presentAndLoad))
                    }
                    
                    NavigationLink("Sheets: Load data then present") {
                        LoadThenPresentView(store: store.scope(state: \.loadThenPresent, action: Root.Action.loadThenPresent))
                    }
                }
                
                Section("Higher-Order Reducers") {
                    NavigationLink("Reusable favoriting component") {
                        EpisodesView(store: store.scope(state: \.reusableFavoriting, action: Root.Action.reusableFavoriting))
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
