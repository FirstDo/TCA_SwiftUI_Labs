import UIKit
import Combine

import ComposableArchitecture
import Then
import CombineCocoa

struct EffectCancellation: Reducer {
  private let network = NetworkManager()
  private enum CancelID {
    case factRequest
  }
  
  struct State: Equatable {
    var number = 0
    var currentFact: String?
    var isFactRequestInFlight = false
  }
  
  enum Action {
    case cancelButtonTapped
    case stepperChanged(Int)
    case factButtonTapped
    case factResponse(TaskResult<String>)
  }
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .cancelButtonTapped:
      state.isFactRequestInFlight = false
      return .cancel(id: CancelID.factRequest)
      
    case let .stepperChanged(value):
      state.number = value
      state.currentFact = nil
      state.isFactRequestInFlight = false
      return .cancel(id: CancelID.factRequest)
      
    case .factButtonTapped:
      state.currentFact = nil
      state.isFactRequestInFlight = true
      
      return .run { [number = state.number] send in
        await send(.factResponse(
          TaskResult {
            try await self.network.fetch(number: number)
          }
        ))
      }
      .cancellable(id: CancelID.factRequest)
      
    case let .factResponse(.success(response)):
      state.isFactRequestInFlight = false
      state.currentFact = response
      return .none
      
    case .factResponse(.failure):
      state.isFactRequestInFlight = false
      return .none
    }
  }
}

class EffectCancellactionVC: BaseVC<EffectCancellation> {
  
  private let label = UILabel().then {
    $0.textColor = .label
  }
  
  private let stepper = UIStepper().then {
    $0.minimumValue = -100
    $0.maximumValue = 100
  }
  
  private let numberFactButton = UIButton().then {
    $0.setTitleColor(.label, for: .normal)
    $0.setTitle("Number Fact", for: .normal)
  }
  
  private let cancelButton = UIButton().then {
    $0.setTitleColor(.label, for: .normal)
    $0.isHidden = true
    $0.setTitle("Cancel", for: .normal)
  }
  
  private let loadingIndicator = UIActivityIndicatorView(style: .medium)
  
  private let resultLabel = UILabel().then {
    $0.textColor = .label
    $0.numberOfLines = 0
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func setup() {
    let hStack = UIStackView(arrangedSubviews: [label, UIView(), stepper])
    hStack.spacing = 10
    view.addSubview(hStack)
    
    let hStack2 = UIStackView(arrangedSubviews: [numberFactButton, cancelButton, UIView(), loadingIndicator])
    hStack2.spacing = 10
    view.addSubview(hStack2)
    
    let vStack = UIStackView(arrangedSubviews: [hStack, hStack2, resultLabel])
    vStack.axis = .vertical
    vStack.spacing = 10
    view.addSubview(vStack)
    
    vStack.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(50)
      $0.centerY.equalToSuperview()
    }
  }
  
  override func bind() {
    stepper.valuePublisher
      .map { Int($0) }
      .sink { [unowned self] num in
        viewStore.send(.stepperChanged(num))
      }
      .store(in: &cancelBag)
    
    numberFactButton.tapPublisher
      .sink { [unowned self] in
        viewStore.send(.factButtonTapped)
      }
      .store(in: &cancelBag)
    
    cancelButton.tapPublisher
      .sink { [unowned self] in
        viewStore.send(.cancelButtonTapped)
      }
      .store(in: &cancelBag)
    
    viewStore.publisher.isFactRequestInFlight
      .sink { [unowned self] state in
        state
          ? loadingIndicator.startAnimating()
          : loadingIndicator.stopAnimating()
        
        numberFactButton.isHidden = state
        cancelButton.isHidden = !state
      }
      .store(in: &cancelBag)
    
    viewStore.publisher.number
      .map { String($0) }
      .assign(to: \.text, on: label)
      .store(in: &cancelBag)
    
    viewStore.publisher.currentFact
      .assign(to: \.text, on: resultLabel)
      .store(in: &cancelBag)
  }
}
