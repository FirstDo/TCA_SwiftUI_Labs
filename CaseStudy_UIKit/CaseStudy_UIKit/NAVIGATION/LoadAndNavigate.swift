import UIKit

import CombineCocoa
import ComposableArchitecture
import Then
import SnapKit

struct LoadAndNavigate: Reducer {
    struct State: Equatable {
        var optionalCounter: Counter.State?
        var isActivityIndicatorHidden = true
    }
    
    enum Action {
        case onDisappear
        case optionalCounter(Counter.Action)
        case setNavigation(isActive: Bool)
        case setNavigationIsActiveDelayCompleted
    }
    
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case load }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onDisappear:
                return .cancel(id: CancelID.load)
                
            case .setNavigation(isActive: true):
                state.isActivityIndicatorHidden = false
                return .run { send in
                    try await self.clock.sleep(for: .seconds(1))
                    await send(.setNavigationIsActiveDelayCompleted)
                }
                .cancellable(id: CancelID.load)
                
            case .setNavigation(isActive: false):
                state.optionalCounter = nil
                return .cancel(id: CancelID.load)
                
            case .setNavigationIsActiveDelayCompleted:
                state.isActivityIndicatorHidden = true
                state.optionalCounter = .init()
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

final class LoadAndNavigateVC: BaseVC<LoadAndNavigate> {
    private var counterView: CounterView!
    
    private let button = UIButton(configuration: .borderedProminent()).then {
        $0.configuration?.title = "Load optional counter"
    }
    
    private let indicator = UIActivityIndicatorView(style: .large).then {
        $0.color = .red
        $0.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)

      if !isMovingToParent {
        viewStore.send(.setNavigation(isActive: false))
      }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewStore.send(.onDisappear)
    }
    
    override func setup() {
        let hstack = UIStackView(arrangedSubviews: [button, indicator])
        hstack.spacing = 10
        view.addSubview(hstack)
        
        hstack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    override func bind() {
        viewStore.publisher.isActivityIndicatorHidden
            .assign(to: \.isHidden, on: indicator)
            .store(in: &cancelBag)
        
        store.scope(state: \.optionalCounter, action: LoadAndNavigate.Action.optionalCounter)
            .ifLet { [unowned self] store in
                navigationController?.pushViewController(CounterVC(store: store), animated: true)
            } else: { [unowned self] in
                navigationController?.popToViewController(self, animated: true)
            }
            .store(in: &cancelBag)
        
        button.tapPublisher
            .sink { [unowned self] _ in
                viewStore.send(.setNavigation(isActive: true))
            }
            .store(in: &cancelBag)
    }
}
