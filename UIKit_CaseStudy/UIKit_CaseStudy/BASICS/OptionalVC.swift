import UIKit

import ComposableArchitecture
import Then
import SnapKit

struct OptionalBasics: ReducerProtocol {
  struct State: Equatable {
    var optionalCounter: Counter.State?
  }
  
  enum Action {
    case optionalCounter(Counter.Action)
    case toggleCounterButtonTapped
  }
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .toggleCounterButtonTapped:
        state.optionalCounter =
        state.optionalCounter == nil
        ? Counter.State()
        : nil
        return .none
        
      case .optionalCounter:
        return .none
      }
    }
    .ifLet(\.optionalCounter, action: /Action.optionalCounter) {
      Counter()
    }
  }
}

final class OptionalVC: BaseVC<OptionalBasics> {
  
  private var counterView: CounterView?
  
  private let button = UIButton().then {
    $0.setTitle("Toggle counter state.", for: .normal)
    $0.setTitleColor(.label, for: .normal)
  }
  
  override func setup() {
    store
      .scope(state: \.optionalCounter, action: OptionalBasics.Action.optionalCounter)
      .ifLet { [unowned self] counterStore in
        
        counterView = CounterView(store: counterStore)

        view.addSubview(counterView!)        
        counterView?.snp.makeConstraints {
          $0.centerX.equalToSuperview()
          $0.width.height.equalTo(200)
          $0.top.equalTo(button.snp.bottom).offset(100)
        }
      } else: { [unowned self] in
        counterView?.removeFromSuperview()
      }
      .store(in: &cancelBag)
    
    view.addSubview(button)
    
    button.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  override func bind() {
    button.tapPublisher
      .sink { [weak self] _ in
        self?.viewStore.send(.toggleCounterButtonTapped)
      }
      .store(in: &cancelBag)
  }
}
