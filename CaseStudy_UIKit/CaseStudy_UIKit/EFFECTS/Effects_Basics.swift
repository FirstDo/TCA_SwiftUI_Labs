

import UIKit
import Combine

import ComposableArchitecture
import CombineCocoa
import Then
struct NetworkManager {
    func fetch(number: Int) async throws -> String {
        try await Task.sleep(for: .seconds(3))
        let (data, _) = try await URLSession.shared
            .data(from: URL(string: "http://numbersapi.com/\(number)/trivia")!)
        return String(decoding: data, as: UTF8.self)
    }
}

struct EffectsBasics: ReducerProtocol {
    struct State: Equatable {
        var number = 0
        var isFlight = false
        var numberFact: String?
    }
    
    enum Action: Equatable {
        case increaseTap
        case decreaseTap
        case decrementDelayResponse
        case numberFactButtonTap
        case numberFactResponse(TaskResult<String>)
    }
    
    private enum CancelID { case delay }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .decreaseTap:
            state.number -= 1
            state.numberFact = nil
            
            return state.number >= 0
            ? .none
            : .run { send in
                try await Task.sleep(for: .seconds(1))
                await send(.decrementDelayResponse)
            }
            .cancellable(id: CancelID.delay)
            
        case .decrementDelayResponse:
            if state.number < 0 {
                state.number += 1
            }
            return .none
            
        case .increaseTap:
            state.number += 1
            state.numberFact = nil
            return state.number >= 0
            ? .cancel(id: CancelID.delay)
            : .none
            
        case .numberFactButtonTap:
            state.isFlight = true
            state.numberFact = nil
            
            return .run { [number = state.number] send in
                await send(.numberFactResponse(TaskResult {
                    try await NetworkManager().fetch(number: number)
                }))
            }
            
        case let .numberFactResponse(.success(response)):
            state.isFlight = false
            state.numberFact = response
            return .none
            
        case .numberFactResponse(.failure):
            state.isFlight = false
            return .none
        }
    }
}

class EffectsBasicsVC: BaseVC<EffectsBasics> {
    
    private let indicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
    }
    private let label = UILabel().then { v in
        v.font = .monospacedDigitSystemFont(ofSize: 60, weight: .bold)
    }
    private let minusButton = UIButton().then { v in
        v.setImage(UIImage(systemName: "minus"), for: .normal)
    }
    private let plusButton = UIButton().then { v in
        v.setImage(UIImage(systemName: "plus"), for: .normal)
    }
    private let factButton = UIButton().then { v in
        v.setTitle("Number Fact", for: .normal)
        v.setTitleColor(.label, for: .normal)
    }
    private let factLabel = UILabel().then { v in
        v.textColor = .label
    }
    
    override func setup() {
        let stack = UIStackView(arrangedSubviews: [minusButton, label, plusButton])
        stack.spacing = 20
        stack.distribution = .fillEqually
        
        let vstack = UIStackView(arrangedSubviews: [stack, factButton, indicator, factLabel])
        vstack.axis = .vertical
        vstack.spacing = 20
        
        view.addSubview(vstack)
        vstack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    override func bind() {
        minusButton.tapPublisher
            .sink { [unowned self] _ in
                viewStore.send(.decreaseTap)
            }
            .store(in: &cancelBag)
        
        plusButton.tapPublisher
            .sink { [unowned self] _ in
                viewStore.send(.increaseTap)
            }
            .store(in: &cancelBag)
        
        factButton.tapPublisher
            .sink { [unowned self] _ in
                viewStore.send(.numberFactButtonTap)
            }
            .store(in: &cancelBag)
        
        viewStore.publisher.number
            .map { String($0) }
            .assign(to: \.text, on: label)
            .store(in: &cancelBag)
        
        viewStore.publisher.isFlight
            .sink { [unowned self] bool in
                if bool {
                    indicator.startAnimating()
                } else {
                    indicator.stopAnimating()
                }
            }
            .store(in: &cancelBag)
        
        viewStore.publisher.numberFact
            .sink { [unowned self] text in
                factLabel.text = text
                
                if let text {
                    factLabel.isHidden = false
                } else {
                    factLabel.isHidden = true
                }
            }
            .store(in: &cancelBag)
    }
}
