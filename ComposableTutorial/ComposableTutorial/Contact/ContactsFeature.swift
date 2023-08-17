import Foundation
import ComposableArchitecture

struct Contact: Equatable, Identifiable {
    let id: UUID
    var name: String
    
    static let dummy: IdentifiedArrayOf<Self> = [
        Contact(id: UUID(), name: "도연"),
        Contact(id: UUID(), name: "경훈"),
        Contact(id: UUID(), name: "유민"),
        Contact(id: UUID(), name: "종민"),
    ]
}


struct ContactsFeature: Reducer {
    struct State: Equatable {
        var contacts: IdentifiedArrayOf<Contact> = []
        
        mutating func addContact(_ contact: Contact) {
            contacts.append(contact)
        }
    }
    
    enum Action: Equatable {
        case addButtonTapped
        case itemTapped(contact: Contact)
        case deleteButtonTapped(id: Contact.ID)
        case addContactDelegate(AddContactFeature.Action.Delegate)
        case addDetailDelegate(ContactDetailFeature.Action.Delegate)
    }
    
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                return .none
                
            case .itemTapped:
                return .none
                
            case let .deleteButtonTapped(id):
                return .none
                
            case let .addContactDelegate(.saveContact(contact)):
                state.contacts.append(contact)
                return .none
                
            case let .addDetailDelegate(.confirmDeletion(id)):
                state.contacts.remove(id: id)
                return .none
                
            default:
                print("Action: ", action)
                return .none
            }
        }
    }
}
