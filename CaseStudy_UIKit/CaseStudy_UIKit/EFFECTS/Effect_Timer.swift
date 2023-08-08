import UIKit

import CombineCocoa
import ComposableArchitecture
import Then
import SnapKit

struct EffectTimer: Reducer {
    struct State: Equatable {
        var isTimerActive = false
        var secondsElapsed = 0
    }
    
    enum Action {
        case onDisappear
        case timerTicked
        case toggleTimerButtonTapped
    }
    
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case timer }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onDisappear:
            return .cancel(id: CancelID.timer)
        case .timerTicked:
            state.secondsElapsed += 1
            return .none
            
        case .toggleTimerButtonTapped:
            state.isTimerActive.toggle()
            return .run { [isActive = state.isTimerActive] send in
                guard isActive else { return }
                for await _ in self.clock.timer(interval: .seconds(1)) {
                    await send(.timerTicked)
                }
            }
            .cancellable(id: CancelID.timer, cancelInFlight: true)
        }
    }
}

final class EffectTimerVC: BaseVC<EffectTimer> {
    private let label = UILabel().then {
        $0.font = .monospacedDigitSystemFont(ofSize: 60, weight: .semibold)
        $0.textColor = .label
    }
    
    private let button = UIButton(configuration: .borderedProminent()).then {
        $0.configuration?.title = "Start"
    }
    
    override func setup() {
        let vstack = UIStackView(arrangedSubviews: [label, button])
        vstack.spacing = 20
        vstack.axis = .vertical
        vstack.alignment = .center
        
        view.addSubview(vstack)
        vstack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(300)
        }
    }
    
    override func bind() {
        viewStore.publisher.isTimerActive
            .sink { [unowned self] state in
                button.configuration?.title = state ? "Stop" : "Start"
            }
            .store(in: &cancelBag)
        
        viewStore.publisher.secondsElapsed
            .map { String($0) }
            .assign(to: \.text, on: label)
            .store(in: &cancelBag)
        
        button.tapPublisher
            .sink { [unowned self] in
                viewStore.send(.toggleTimerButtonTapped)
            }
            .store(in: &cancelBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewStore.send(.onDisappear)
    }
}
