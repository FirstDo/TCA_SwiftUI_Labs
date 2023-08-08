import ComposableArchitecture

struct Root: Reducer {
    struct State: Equatable {
        var counter = Counter.State()
        var twoCounter = TwoCounter.State()
        var bindings = Bindings.State()
        var bindingsForm = BindingsForm.State()
        var optionalCounter = OptionalCounter.State()
        var sharedState = SharedState.State()
        var alertAndConfirmationDialog = AlertAndConfirmationDialog.State()
        var focus = Focus.State()
        var animations = Animations.State()
        
        var effectBasics = Effects_Basics.State()
        var effectCancellation = EffectsCancellation.State()
        var effectLongLiving = LongLivingEffects.State()
        var effectRefreshable = Refreshable.State()
        var effectTimers = Timers.State()
        var effectWebSocket = WebSocket.State()
        
        var stack = NavigationDemo.State()
        var loadThenNavigate = LoadThenNavigate.State()
        var navigateAndLoad = NavigateAndLoad.State()
        var loadThenPresent = LoadThenPresent.State()
        var presentAndLoad = PresentAndLoad.State()
        var navigateAndLoadList = NavigateAndLoadList.State()
        var loadThenNavigateList = LoadThenNavigateList.State()
        
        var reusableFavoriting = Episodes.State()
    }
    
    enum Action {
        case onAppear
        case counter(Counter.Action)
        case twoCounter(TwoCounter.Action)
        case bindings(Bindings.Action)
        case bindingsForm(BindingsForm.Action)
        case optionalCounter(OptionalCounter.Action)
        case sharedState(SharedState.Action)
        case alert(AlertAndConfirmationDialog.Action)
        case focus(Focus.Action)
        case animation(Animations.Action)
        
        case effectBasics(Effects_Basics.Action)
        case effectCancellaiton(EffectsCancellation.Action)
        case effectLongLiving(LongLivingEffects.Action)
        case effectRefreshable(Refreshable.Action)
        case effectTimer(Timers.Action)
        case effectWebSocket(WebSocket.Action)
        
        case stack(NavigationDemo.Action)
        case loadThenNavigate(LoadThenNavigate.Action)
        case naviageAndLoad(NavigateAndLoad.Action)
        case loadThenPresent(LoadThenPresent.Action)
        case presentAndLoad(PresentAndLoad.Action)
        case navigateAndLoadList(NavigateAndLoadList.Action)
        case loadThenNavigateList(LoadThenNavigateList.Action)
        case reusableFavoriting(Episodes.Action)
        
    }
    
    @Dependency(\.continuousClock) var clock
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state = .init()
                return .none
                
            default:
                return .none
            }
        }
        
        Scope(state: \.counter, action: /Action.counter) { Counter() }
        Scope(state: \.twoCounter, action: /Action.twoCounter) { TwoCounter() }
        Scope(state: \.bindings, action: /Action.bindings) { Bindings() }
        Scope(state: \.bindingsForm, action: /Action.bindingsForm) { BindingsForm() }
        Scope(state: \.optionalCounter, action: /Action.optionalCounter) { OptionalCounter() }
        Scope(state: \.sharedState, action: /Action.sharedState) { SharedState() }
        Scope(state: \.alertAndConfirmationDialog, action: /Action.alert) { AlertAndConfirmationDialog() }
        Scope(state: \.focus, action: /Action.focus) { Focus() }
        Scope(state: \.animations, action: /Action.animation) { Animations() }
        
        Scope(state: \.effectBasics, action: /Action.effectBasics) { Effects_Basics() }
        Scope(state: \.effectCancellation, action: /Action.effectCancellaiton) { EffectsCancellation() }
        Scope(state: \.effectLongLiving, action: /Action.effectLongLiving) { LongLivingEffects() }
        Scope(state: \.effectRefreshable, action: /Action.effectRefreshable) { Refreshable() }
        Scope(state: \.effectTimers, action: /Action.effectTimer) { Timers() }
        Scope(state: \.effectWebSocket, action: /Action.effectWebSocket) { WebSocket() }
        
        Scope(state: \.stack, action: /Action.stack) { NavigationDemo() }
        Scope(state: \.loadThenNavigate, action: /Action.loadThenNavigate) { LoadThenNavigate() }
        Scope(state: \.navigateAndLoad, action: /Action.naviageAndLoad) { NavigateAndLoad() }
        Scope(state: \.loadThenPresent, action: /Action.loadThenPresent) { LoadThenPresent() }
        Scope(state: \.presentAndLoad, action: /Action.presentAndLoad) { PresentAndLoad() }
        Scope(state: \.navigateAndLoadList, action: /Action.navigateAndLoadList) { NavigateAndLoadList() }
        Scope(state: \.loadThenNavigateList, action: /Action.loadThenNavigateList) { LoadThenNavigateList() }
        
        Scope(state: \.reusableFavoriting, action: /Action.reusableFavoriting) { Episodes(favorite: favorite(id:isFavorite:)) }
    }
}
