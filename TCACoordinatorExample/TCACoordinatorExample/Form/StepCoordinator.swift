import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct StepCoordinatorView: View {
  let store: StoreOf<StepCoordinator>
  
  var body: some View {
    TCARouter(store) { screen in
      SwitchStore(screen) { screen in
        switch screen {
        case .step1:
          CaseLet(/StepScreen.State.step1, action: StepScreen.Action.step1, then: Step1View.init(store:))
        case .step2:
          CaseLet(/StepScreen.State.step2, action: StepScreen.Action.step2, then: Step2View.init(store:))
        case .step3:
          CaseLet(/StepScreen.State.step3, action: StepScreen.Action.step3, then: Step3View.init(store:))
        case .submit:
          CaseLet(/StepScreen.State.submit, action: StepScreen.Action.submit, then: SubmitView.init(store:))
        }
      }
    }
  }
}

struct StepCoordinator: Reducer {
  struct State: Equatable, IdentifiedRouterState {
    static let initialState = Self(routeIDs: [.root(.step1, embedInNavigationView: true)])
    
    var step1 = Step1Core.State()
    var step2 = Step2Core.State()
    var step3 = Step3Core.State()
    
    var finalScreen: SubmitCore.State {
      return .init(
        firstName: step1.firstName,
        lastName: step1.lastName,
        dateOfBirth: step2.date,
        job: step3.selectedJob
      )
    }
    
    var routeIDs: IdentifiedArrayOf<Route<StepScreen.State.ID>>
    
    var routes: IdentifiedArrayOf<Route<StepScreen.State>> {
      get {
        let routes = routeIDs.map { route -> Route<StepScreen.State> in
          route.map { id in
            switch id {
            case .step1:
              return .step1(step1)
            case .step2:
              return .step2(step2)
            case .step3:
              return .step3(step3)
            case .submit:
              return .submit(finalScreen)
            }
          }
        }
        
        return IdentifiedArray(uniqueElements: routes)
      }
      set {
        let routeIDs = newValue.map { route -> Route<StepScreen.State.ID> in
          route.map { id in
            switch id {
            case let .step1(state):
              self.step1 = state
              return .step1
              
            case let .step2(state):
              self.step2 = state
              return .step2
              
            case let .step3(state):
              self.step3 = state
              return .step3
              
            case .submit:
              return .submit
            }
          }
        }
        self.routeIDs = IdentifiedArray(uniqueElements: routeIDs)
      }
    }
  }
  
  enum Action: IdentifiedRouterAction {
    case updateRoutes(IdentifiedArrayOf<Route<StepScreen.State>>)
    case routeAction(StepScreen.State.ID, action: StepScreen.Action)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .routeAction(_, action: .step1(.nextButtonTapped)):
        state.routeIDs.push(.step2)
        
      case .routeAction(_, action: .step2(.nextButtonTapped)):
        state.routeIDs.push(.step3)
        
      case .routeAction(_, action: .step3(.nextButtonTapped)):
        state.routeIDs.push(.submit)
        
      case .routeAction(_, action: .submit(.returnToName)):
        state.routeIDs.goBackTo(id: .step1)
        
      case .routeAction(_, action: .submit(.returnToDateOfBirth)):
        state.routeIDs.goBackTo(id: .step2)
        
      case .routeAction(_, action: .submit(.returToJob)):
        state.routeIDs.goBackTo(id: .step3)
        
      default:
        break
      }
      return .none
    }
    .forEachRoute {
      StepScreen()
    }
  }
}
