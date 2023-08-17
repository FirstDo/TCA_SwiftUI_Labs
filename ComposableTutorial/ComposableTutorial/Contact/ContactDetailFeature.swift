import ComposableArchitecture

struct ContactDetailFeature: Reducer {
    struct State: Equatable {
        let contact: Contact
    }
    
    enum Action: Equatable {
        case delegate(Delegate)
        case deleteButtonTapped
        
        enum Delegate: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            case .deleteButtonTapped:
                return .send(.delegate(.confirmDeletion(id: state.contact.id)))
                
            }
        }
    }
}
