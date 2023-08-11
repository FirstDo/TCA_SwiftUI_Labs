import Foundation
import ComposableArchitecture

struct Contact: Equatable, Identifiable {
    let id: UUID
    var name: String
}

extension ContactsFeature {
    struct Destination: Reducer {
        enum State: Equatable {
            case addContact(AddContactFeature.State)
            case alert(AlertState<ContactsFeature.Action.Alert>)
        }
        
        
        enum Action: Equatable {
            case addContact(AddContactFeature.Action)
            case alert(ContactsFeature.Action.Alert)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.addContact, action: /Action.addContact) {
                AddContactFeature()
            }
            
            
        }
    }
}

struct ContactsFeature: Reducer {
    struct State: Equatable {
        @PresentationState var destionation: Destination.State?
        var contacts: IdentifiedArrayOf<Contact> = [
            Contact(id: UUID(), name: "도연"),
            Contact(id: UUID(), name: "경훈"),
            Contact(id: UUID(), name: "유민"),
        ]
    }
    
    enum Action: Equatable {
        case addButtonTapped
        case deleteButtonTapped(id: Contact.ID)
        case destination(PresentationAction<Destination.Action>)
        enum Alert: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.destionation = .addContact(.init(contact: Contact(id: UUID(), name: "")))
                return .none
                
            case let .destination(.presented(.addContact(.delegate(.saveContact(contact))))):
                state.contacts.append(contact)
                return .none
                
            case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
                state.contacts.remove(id: id)
                return .none
                
            case .destination:
                return .none
                
            case let .deleteButtonTapped(id):
                state.destionation = .alert(.init(
                    title: { TextState("Are you sure?")},
                    actions: {
                        ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                            TextState("Delete")
                        }
                    }
                ))
                
                return .none
            }
        }
        .ifLet(\.$destionation, action: /Action.destination) {
            Destination()
        }
    }
}
