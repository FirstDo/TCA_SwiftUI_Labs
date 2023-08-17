import ComposableArchitecture

struct Screen: Reducer {
    enum State: Equatable {
        case list(ContactsFeature.State)
        case detail(ContactDetailFeature.State)
        case add(AddContactFeature.State)
    }
    
    enum Action: Equatable {
        case list(ContactsFeature.Action)
        case detail(ContactDetailFeature.Action)
        case add(AddContactFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.list, action: /Action.list) { ContactsFeature() }
        Scope(state: /State.detail, action: /Action.detail) { ContactDetailFeature() }
        Scope(state: /State.add, action: /Action.add) { AddContactFeature() }
    }
}
