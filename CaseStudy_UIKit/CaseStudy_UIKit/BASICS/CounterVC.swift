import UIKit
import Combine

import CombineCocoa
import Then
import ComposableArchitecture

struct Counter: Reducer {
    struct State: Equatable, Identifiable {
        let id = UUID()
        var count = 0
    }
    
    enum Action {
        case tapDecrement
        case tapIncrement
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .tapDecrement:
            state.count -= 1
            return .none
        case .tapIncrement:
            state.count += 1
            return .none
        }
    }
}

class CounterView: UIView {
    private let viewStore: ViewStoreOf<Counter>
    private var cancelBag = Set<AnyCancellable>()
    
    private let label = UILabel().then { v in
        v.font = .monospacedDigitSystemFont(ofSize: 60, weight: .bold)
    }
    private let minusButton = UIButton().then { v in
        v.setImage(UIImage(systemName: "minus"), for: .normal)
    }
    private let plusButton = UIButton().then { v in
        v.setImage(UIImage(systemName: "plus"), for: .normal)
    }
    
    init(store: StoreOf<Counter>) {
        self.viewStore = ViewStore(store, observe: { $0 })
        super.init(frame: .zero)
        
        setup()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        let stack = UIStackView(arrangedSubviews: [minusButton, label, plusButton])
        stack.spacing = 20
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func bind() {
        viewStore.publisher
            .map { "\($0.count)" }
            .assign(to: \.text, on: label)
            .store(in: &cancelBag)
        
        minusButton.tapPublisher
            .sink { [weak self] _ in
                self?.viewStore.send(.tapDecrement)
            }
            .store(in: &cancelBag)
        
        plusButton.tapPublisher
            .sink { [weak self] _ in
                self?.viewStore.send(.tapIncrement)
            }
            .store(in: &cancelBag)
    }
}

class CounterVC: BaseVC<Counter> {
    
    override func setup() {
        let counterView = CounterView(store: self.store)
        
        view.addSubview(counterView)
        counterView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
