import UIKit

import CombineCocoa
import ComposableArchitecture
import SnapKit

struct Bindings: ReducerProtocol {
    struct State: Equatable {
        var sliderValue = 5.0
        var stepCount = 10
        var text = ""
        var toggleIsOn = false
    }
    
    enum Action {
        case sliderValueChanged(Double)
        case stepCountChange(Int)
        case textChanged(String)
        case toggleChanged(Bool)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .sliderValueChanged(value):
            state.sliderValue = value
            return .none
            
        case let .stepCountChange(count):
            state.sliderValue = .minimum(state.sliderValue, Double(count))
            state.stepCount = count
            return .none
            
        case let .textChanged(text):
            state.text = text.enumerated().map {
                $0.offset.isMultiple(of: 2)
                ? $0.element.uppercased()
                : $0.element.lowercased()
            }
            .joined()
            
            return .none
            
        case let .toggleChanged(isOn):
            state.toggleIsOn = isOn
            return .none
        }
    }
}

class BindingsVC: BaseVC<Bindings> {
    
    private let textField = UITextField().then {
        $0.placeholder = "Type here"
    }
    
    private let controlLabel = UILabel().then {
        $0.text = "Disable other controls"
    }
    private let controlSwitch = UISwitch()
    
    private let stepperLabel = UILabel().then {
        $0.text = "Max slider value: 0"
    }
    private let stepper = UIStepper().then {
        $0.minimumValue = .zero
        $0.maximumValue = 20
    }
    
    private let sliderLabel = UILabel().then {
        $0.text = "Slider value: 0"
    }
    private let slider = UISlider().then {
        $0.minimumValue = 0
    }
    
    override func setup() {
        let switchStack = makeHStack(label: controlLabel, control: controlSwitch)
        let stepperStack = makeHStack(label: stepperLabel, control: stepper)
        let sliderStack = makeHStack(label: sliderLabel, control: slider)
        
        let vstack = UIStackView(arrangedSubviews: [textField, switchStack, stepperStack, sliderStack])
        vstack.axis = .vertical
        vstack.distribution = .fillEqually
        
        view.addSubview(vstack)
        vstack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(300)
        }
    }
    
    override func bind() {
        textField.textPublisher
            .sink { [unowned self] text in
                viewStore.send(.textChanged(text!))
            }
            .store(in: &cancelBag)
        
        controlSwitch.isOnPublisher
            .sink { [unowned self] isOn in
                viewStore.send(.toggleChanged(isOn))
            }
            .store(in: &cancelBag)
        
        stepper.valuePublisher
            .sink { [unowned self] value in
                viewStore.send(.stepCountChange(Int(value)))
            }
            .store(in: &cancelBag)
        
        slider.valuePublisher
            .sink { [unowned self] value in
                viewStore.send(.sliderValueChanged(Double(value)))
            }
            .store(in: &cancelBag)
        
        viewStore.publisher.toggleIsOn
            .sink { [unowned self] isOn in
                textField.isEnabled = isOn
                stepper.isEnabled = isOn
                slider.isEnabled = isOn
            }
            .store(in: &cancelBag)
        
        viewStore.publisher.text
            .sink { [unowned self] text in
                textField.text = text
            }
            .store(in: &cancelBag)
        
        viewStore.publisher.stepCount
            .sink { [unowned self] value in
                slider.maximumValue = Float(value)
                stepperLabel.text = "Max Slider value: \(value)"
            }
            .store(in: &cancelBag)
        
        viewStore.publisher.sliderValue
            .sink { [unowned self] value in
                sliderLabel.text = "Slider value: \(Int(value))"
            }
            .store(in: &cancelBag)
    }
    
    private func makeHStack(label: UILabel, control: UIControl) -> UIStackView {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        
        let stack = UIStackView(arrangedSubviews: [label, spacer, control])
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }
}
