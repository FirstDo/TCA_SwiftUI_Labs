import UIKit
import Combine

import ComposableArchitecture
import Then
import CombineCocoa
import SnapKit

struct SharedState: Reducer {
  enum Tab {
    case counter, profile
  }
  
  struct State: Equatable {
    var counter = Counter.State()
    var currentTab = Tab.counter
    
    var profile: Profile.State {
      get {
        Profile.State(
          currentTab: self.currentTab,
          count: self.counter.count,
          maxCount: self.counter.maxCount,
          minCount: self.counter.minCount,
          numberOfCounts: self.counter.numberOfCounts
        )
      }
      set {
        self.currentTab = newValue.currentTab
        self.counter.count = newValue.count
        self.counter.maxCount = newValue.maxCount
        self.counter.minCount = newValue.minCount
        self.counter.numberOfCounts = newValue.numberOfCounts
      }
    }
  }
  
  enum Action {
    case counter(Counter.Action)
    case profile(Profile.Action)
    case selectTab(Tab)
  }
  
  var body: some Reducer<State, Action> {
    Scope(state: \.counter, action: /Action.counter) {
      Counter()
    }
    Scope(state: \.profile, action: /Action.profile) {
      Profile()
    }
    
    Reduce { state, action in
      switch action {
      case .counter, .profile:
        return .none
      case let .selectTab(tab):
        state.currentTab = tab
        return .none
      }
    }
  }
  
  struct Counter: Reducer {
    struct State: Equatable {
      var alert: AlertState<Action>?
      var count = 0
      var maxCount = 0
      var minCount = 0
      var numberOfCounts = 0
    }
    
    enum Action: Equatable {
      case alertDismissed
      case decrementButtonTapped
      case incrementButtonTapped
      case isPrimeButtonTapped
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
      switch action {
      case .alertDismissed:
        state.alert = nil
        return .none
        
      case .decrementButtonTapped:
        state.count -= 1
        state.numberOfCounts += 1
        state.minCount = min(state.minCount, state.count)
        return .none
        
      case .incrementButtonTapped:
        state.count += 1
        state.numberOfCounts += 1
        state.maxCount = max(state.maxCount, state.count)
        return .none
        
      case .isPrimeButtonTapped:
        state.alert = AlertState {
          TextState(
            isPrime(state.count)
              ? "👍 The number \(state.count) is prime!"
              : "👎 The number \(state.count) is not prime :("
          )
        }
        
        return .none
      }
    }
  }
  
  struct Profile: Reducer {
    struct State: Equatable {
      private(set) var currentTab: Tab
      private(set) var count = 0
      private(set) var maxCount: Int
      private(set) var minCount: Int
      private(set) var numberOfCounts: Int
      
      fileprivate mutating func resetCount() {
        self.currentTab = .counter
        self.count = 0
        self.maxCount = 0
        self.maxCount = 0
        self.numberOfCounts = 0
      }
    }
    
    enum Action: Equatable {
      case resetCounterButtonTapped
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
      switch action {
      case .resetCounterButtonTapped:
        state.resetCount()
        return .none
      }
    }
  }
}

class SharedVC: BaseVC<SharedState> {
  private let counterView: SharedStateCounterView
  private let profileView: SharedStateProfileView
  
  private let segmentControl = UISegmentedControl(items: ["Counter", "Profile"]).then {
    $0.selectedSegmentIndex = 0
  }
  
  
  override init(store: StoreOf<SharedState>) {
    self.counterView = SharedStateCounterView(
      store: store.scope(state: \.counter, action: SharedState.Action.counter)
    )
    self.profileView = SharedStateProfileView(
      store: store.scope(state: \.profile, action: SharedState.Action.profile)
    )
    super.init(store: store)
  }

  override func setup() {
    view.addSubview(segmentControl)
    segmentControl.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
    }
    
    view.addSubview(counterView)
    counterView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    
    profileView.isHidden = true
    
    view.addSubview(profileView)
    profileView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  override func bind() {
    segmentControl.selectedSegmentIndexPublisher
      .sink { [unowned self] index in
        if index == 0 {
          counterView.isHidden = false
          profileView.isHidden = true
        } else {
          counterView.isHidden = true
          profileView.isHidden = false
        }
      }
      .store(in: &cancelBag)
  }
}

class SharedStateCounterView: UIView {
  private let store: StoreOf<SharedState.Counter>
  private let viewStore: ViewStoreOf<SharedState.Counter>
  
  private let minusButton = UIButton().then {
    $0.setImage(UIImage(systemName: "minus"), for: .normal)
  }
  
  private let plusButton = UIButton().then {
    $0.setImage(UIImage(systemName: "plus"), for: .normal)
  }
  
  private let valueLabel = UILabel().then {
    $0.textColor = .label
    $0.textAlignment = .center
  }
  
  private let primeButton = UIButton().then {
    $0.setTitle("Is this prime?", for: .normal)
    $0.setTitleColor(.label, for: .normal)
  }
  
  private var cancelBag = Set<AnyCancellable>()
  
  init(store: StoreOf<SharedState.Counter>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
    super.init(frame: .zero)
    
    setup()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let hStack = UIStackView(arrangedSubviews: [minusButton, valueLabel, plusButton])
    hStack.spacing = 10
    hStack.distribution = .fillEqually
    
    let vStack = UIStackView(arrangedSubviews: [hStack, primeButton])
    vStack.spacing = 10
    vStack.distribution = .fillEqually
    vStack.axis = .vertical
    
    addSubview(vStack)
    vStack.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    minusButton.snp.makeConstraints {
      $0.width.height.equalTo(50)
    }
    
    plusButton.snp.makeConstraints {
      $0.width.height.equalTo(50)
    }
  }
  
  private func bind() {
    primeButton.tapPublisher
      .sink { [unowned self] _ in
        viewStore.send(.isPrimeButtonTapped)
      }
      .store(in: &cancelBag)
    
    minusButton.tapPublisher
      .sink { [unowned self] _ in
        viewStore.send(.decrementButtonTapped)
      }
      .store(in: &cancelBag)
    
    plusButton.tapPublisher
      .sink { [unowned self] _ in
        viewStore.send(.incrementButtonTapped)
      }
      .store(in: &cancelBag)
    
    viewStore.publisher
      .map(\.alert)
      .sink { alertState in
        print(alertState)
      }
      .store(in: &cancelBag)
    
    viewStore.publisher
      .map { String($0.count) }
      .assign(to: \.text, on: valueLabel)
      .store(in: &cancelBag)

  }
}

class SharedStateProfileView: UIView {
  private let store: StoreOf<SharedState.Profile>
  private let viewStore: ViewStoreOf<SharedState.Profile>
  
  private let currentCountLabel = UILabel().then {
    $0.textColor = .label
    $0.textAlignment = .center
  }
  
  private let maxLabel = UILabel().then {
    $0.textColor = .label
    $0.textAlignment = .center
  }
  
  private let minLabel = UILabel().then {
    $0.textColor = .label
    $0.textAlignment = .center
  }
  
  private let totalLabel = UILabel().then {
    $0.textColor = .label
    $0.textAlignment = .center
  }
  
  private let resetButton = UIButton().then {
    $0.setTitle("Reset", for: .normal)
    $0.setTitleColor(.blue, for: .normal)
  }
  
  private var cancelBag = Set<AnyCancellable>()
  
  init(store: StoreOf<SharedState.Profile>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
    super.init(frame: .zero)
    
    setup()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let vStack = UIStackView(arrangedSubviews: [currentCountLabel, maxLabel, minLabel, totalLabel, resetButton])
    vStack.axis = .vertical
    vStack.spacing = 10
    
    addSubview(vStack)
    vStack.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func bind() {
    viewStore.publisher
      .map { String($0.count) }
      .sink { [unowned self] num in
        currentCountLabel.text = "Current count: " + num
      }
      .store(in: &cancelBag)
    
    viewStore.publisher.maxCount
      .map { String($0) }
      .sink { [unowned self] num in
        maxLabel.text = "Max count: " + num
      }
      .store(in: &cancelBag)
    
    viewStore.publisher.minCount
      .map { String($0) }
      .sink { [unowned self] num in
        minLabel.text = "Min count: " + num
      }
      .store(in: &cancelBag)
    
    viewStore.publisher.numberOfCounts
      .map { String($0) }
      .sink { [unowned self] num in
        totalLabel.text = "Total number of count events: " + num
      }
      .store(in: &cancelBag)
    
    resetButton.tapPublisher
      .sink { [unowned self] _ in
        viewStore.send(.resetCounterButtonTapped)
      }
      .store(in: &cancelBag)
  }
}

private func isPrime(_ p: Int) -> Bool {
  if p <= 1 { return false }
  if p <= 3 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 { return false }
  }
  return true
}
