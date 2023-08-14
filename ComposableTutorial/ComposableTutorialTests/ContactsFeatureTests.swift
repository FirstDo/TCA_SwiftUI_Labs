import XCTest
import ComposableArchitecture

@testable import ComposableTutorial

@MainActor
final class ContactsFeatureTests: XCTestCase {
    var store: TestStoreOf<ContactsFeature>!

    override func setUpWithError() throws {
        store = TestStore(
            initialState: ContactsFeature.State(),
            reducer: { ContactsFeature() },
            withDependencies: {
                $0.uuid = .incrementing
            }
        )
    }

    override func tearDownWithError() throws {
        store = nil
    }
    
    func test_addFlow() async {
        // addButton을 눌렀을때, destination에 제대로 할당되는지
        await store.send(.addButtonTapped) {
            $0.destination = .addContact(
                AddContactFeature.State(contact: Contact(id: UUID(0), name: ""))
            )
        }
        
        /// setName "DUDU"을 했을때,
        await store.send(.destination(.presented(.addContact(.setName("DUDU"))))) {
            $0.$destination[case: /ContactsFeature.Destination.State.addContact]?.contact.name = "DUDU"
        }
        
        /// saveButtonTapped을 눌렀을때
        await store.send(.destination(.presented(.addContact(.saveButtonTapped))))
        
        /// saveContact Action이 실행됫을때, 연락처배열에 제대로 저장되는지
        await store.receive(.destination(.presented(.addContact(.delegate(.saveContact(Contact(id: UUID(0), name: "DUDU"))))))) {
            $0.contacts = [
                Contact(id: UUID(0), name: "DUDU")
            ]
        }
        
        /// destination dismiss 액션을 받았을때 destination이 nil이 되는지
        await store.receive(.destination(.dismiss)) {
            $0.destination = nil
        }
    }
    
    func test_addFlow_NonExhaustive() async {
        store.exhaustivity = .off
        
        await store.send(.addButtonTapped)
        await store.send(.destination(.presented(.addContact(.setName("DUDU")))))
        await store.send(.destination(.presented(.addContact(.saveButtonTapped))))
        await store.skipReceivedActions()
        
        store.assert { state in
            state.contacts = [
                Contact(id: UUID(0), name: "DUDU")
            ]
            state.destination = nil
        }
    }
    
    func test_deleteContact() async {
        store = TestStore(
            initialState: ContactsFeature.State(contacts: [
                Contact(id: UUID(0), name: "dudu"),
                Contact(id: UUID(1), name: "doyeob"),
            ]),
            reducer: { ContactsFeature() }
        )
        
        await store.send(.deleteButtonTapped(id: UUID(1))) {
            $0.destination = .alert(.deleteConfirmation(id: UUID(1)))
        }
        
        await store.send(.destination(.presented(.alert(.confirmDeletion(id: UUID(1)))))) {
            $0.contacts.remove(id: UUID(1))
            $0.destination = nil
        }
    }
}
