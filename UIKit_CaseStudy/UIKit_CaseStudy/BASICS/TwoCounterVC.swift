import UIKit

import CombineCocoa
import ComposableArchitecture
import Then

struct TwoCounter: ReducerProtocol {
    struct State: Equatable {
        var counter1 = Counter.State()
        var counter2 = Counter.State()
    }
    
    enum Action {
        case counter1(Counter.Action)
        case counter2(Counter.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.counter1, action: /Action.counter1) {
            Counter()
        }
        Scope(state: \.counter2, action: /Action.counter2) {
            Counter()
        }
    }
}

class TwoCounterVC: BaseVC<TwoCounter> {
    
    override func setup() {
        let counter1 = CounterView(store: self.store.scope(
            state: \.counter1,
            action: TwoCounter.Action.counter1
        ))
        let counter2 = CounterView(store: self.store.scope(
            state: \.counter2,
            action: TwoCounter.Action.counter2
        ))
        
        let stack = UIStackView(arrangedSubviews: [counter1, counter2])
        stack.spacing = 20
        stack.axis = .vertical
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(300)
        }
    }
}
