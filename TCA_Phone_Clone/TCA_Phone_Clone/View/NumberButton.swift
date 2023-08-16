import SwiftUI
import ComposableArchitecture

struct NumberFeature: Reducer {
  struct State: Equatable {
    let number: Number?
  }
  
  enum Action: Equatable {
    case numberTab
  }
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .numberTab:
      return .none
    }
  }
}

struct NumberButton: View {
  let store: StoreOf<NumberFeature>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      if let number = viewStore.number {
        VStack {
          Text(number.rawValue)
            .font(.largeTitle)
          if let detail = number.alphabet {
            Text(detail)
              .font(.caption2)
          }
        }
        .padding()
        .frame(width: 80, height: 80)
        .background(Color.black.opacity(0.15), in: Circle())
        
      } else {
        Image(systemName: "phone.fill")
          .resizable()
          .frame(width: 30, height: 30)
          .foregroundColor(.white)
          .frame(width: 80, height: 80)
          .background(Color.black.opacity(0.15), in: Circle())
      }
    }
  }
}

struct NumberButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      NumberButton(store: .init(initialState: NumberFeature.State(number: .one)) {
        NumberFeature()
      })
      NumberButton(store: .init(initialState: NumberFeature.State(number: .two)) {
        NumberFeature()
      })
      NumberButton(store: .init(initialState: NumberFeature.State(number: nil)) {
        NumberFeature()
      })
      NumberButton(store: .init(initialState: NumberFeature.State(number: .hash)) {
        NumberFeature()
      })
    }
  }
}
