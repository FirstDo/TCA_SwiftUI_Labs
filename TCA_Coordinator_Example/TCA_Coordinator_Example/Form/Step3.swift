import SwiftUI
import ComposableArchitecture

struct Step3: Reducer {
    struct State: Equatable {
        var selectedOccupation: String?
        var occupations: [String] = []
    }
    
    enum Action: Equatable {
        case getOccupations
        case receiveOccupations([String])
        case selectOccupation(String)
        case nextButtonTapped
    }
    
    let getOccupations: () async -> [String]
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .getOccupations:
                return .run { send in
                    await send(.receiveOccupations(getOccupations()))
                }
            case let .receiveOccupations(occupations):
                state.occupations = occupations
                return .none
                
            case let .selectOccupation(occupation):
                if state.occupations.contains(occupation) {
                    state.selectedOccupation = state.selectedOccupation == occupation ? nil : occupation
                }
                return .none
                
            case .nextButtonTapped:
                return .none
            }
        }
    }
}

struct Step3View: View {
    let store: StoreOf<Step3>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section("Jobs") {
                    if !viewStore.occupations.isEmpty {
                        List(viewStore.occupations, id: \.self) { occupation in
                            Button {
                                viewStore.send(.selectOccupation(occupation))
                            } label: {
                                HStack {
                                    Text(occupation)
                                    
                                    Spacer()
                                    
                                    if let selected = viewStore.selectedOccupation, selected == occupation {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(.automatic)
                    }
                }
                
                Button("Next") {
                    viewStore.send(.nextButtonTapped)
                }
            }
            .onAppear {
                viewStore.send(.getOccupations)
            }
            .navigationTitle("Step 3")
        }
    }
}

struct Step3View_Previews: PreviewProvider {
    static var previews: some View {
        Step3View(store: .init(initialState: .init()) {
            Step3(getOccupations: {
                [
                  "iOS Developer",
                  "Android Developer",
                  "Web Developer",
                  "Project Manager",
                  "Designer",
                  "The Big Cheese"
                ]
              }
            )
        })
    }
}
