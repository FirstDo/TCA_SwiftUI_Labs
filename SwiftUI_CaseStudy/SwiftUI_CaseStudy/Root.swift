import ComposableArchitecture

struct Root: ReducerProtocol {
    struct State: Equatable {
        var counter = Counter.State()
        var twoCounter = TwoCounter.State()
        var bindings = Bindings.State()
        var bindingsForm = BindingsForm.State()
        var optionalCounter = OptionalCounter.State()
        var sharedState = SharedState.State()
        var alertAndConfirmationDialog = AlertAndConfirmationDialog.State()
        var animations = Animations.State()
        var effectBasics = Effects_Basics.State()
        var effectCancellation = EffectsCancellation.State()
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
        case animation(Animations.Action)
        case effectBasics(Effects_Basics.Action)
        case effectCancellaiton(EffectsCancellation.Action)
    }
    
    @Dependency(\.continuousClock) var clock
    
    var body: some ReducerProtocol<State, Action> {
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
        Scope(state: \.animations, action: /Action.animation) { Animations() }
        Scope(state: \.effectBasics, action: /Action.effectBasics) { Effects_Basics() }
        Scope(state: \.effectCancellation, action: /Action.effectCancellaiton) { EffectsCancellation() }
    }
}
