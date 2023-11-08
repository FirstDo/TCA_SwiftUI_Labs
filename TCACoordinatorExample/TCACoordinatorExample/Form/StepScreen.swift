import ComposableArchitecture

struct StepScreen: Reducer {
  enum State: Equatable, Identifiable {
    case step1(Step1Core.State)
    case step2(Step2Core.State)
    case step3(Step3Core.State)
    case submit(SubmitCore.State)
    
    var id: ID {
      switch self {
      case .step1:
        return .step1
      case .step2:
        return .step2
      case .step3:
        return .step3
      case .submit:
        return .submit
      }
    }
    
    enum ID: Identifiable {
      case step1
      case step2
      case step3
      case submit
      
      var id: ID { return self }
    }
  }
  
  enum Action: Equatable {
    case step1(Step1Core.Action)
    case step2(Step2Core.Action)
    case step3(Step3Core.Action)
    case submit(SubmitCore.Action)
  }
  
  var body: some ReducerOf<Self> {
    Scope(state: /State.step1, action: /Action.step1) {
      Step1Core()
    }
    
    Scope(state: /State.step2, action: /Action.step2) {
      Step2Core()
    }
    
    Scope(state: /State.step3, action: /Action.step3) {
      Step3Core()
    }
    
    Scope(state: /State.submit, action: /Action.submit) {
      SubmitCore()
    }
  }
}
