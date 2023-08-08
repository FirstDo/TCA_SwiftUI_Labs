import UIKit
import Combine

import CombineCocoa
import ComposableArchitecture
import Then
import SnapKit

struct Todo: Reducer {
    struct State: Equatable, Identifiable, Hashable {
        let id: UUID
        var description: String? = "Untitled Todo"
        var isComplete = false
    }
    
    enum Action {
        case checkBoxToggled
        case textFieldChanged(String?)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .checkBoxToggled:
            state.isComplete.toggle()
            return .none
            
        case let .textFieldChanged(text):
            state.description = text
            return .none
        }
    }
}

final class TodoCell: UITableViewCell {
    
    private var store: StoreOf<Todo>?
    private var viewStore: ViewStoreOf<Todo>?
    private var cancelBag = Set<AnyCancellable>()
    
    private let button = UIButton().then {
        $0.setImage(UIImage(systemName: "square"), for: .normal)
    }
    
    private let textField = UITextField().then {
        $0.placeholder = "Untitled Todo"
        $0.textColor = .label
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        print("#function", viewStore?.state.description)
        
        cancelBag.removeAll()
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(button)
        contentView.addSubview(textField)
        
        button.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview().inset(10)
        }
        
        textField.snp.makeConstraints {
            $0.leading.equalTo(button.snp.trailing).offset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(10)
            $0.centerY.equalTo(button)
        }
    }
    
    func bind(store: StoreOf<Todo>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        button.tapPublisher
            .sink { [unowned self] _ in
                viewStore?.send(.checkBoxToggled)
            }
            .store(in: &cancelBag)
        
        textField.textPublisher
            .dropFirst()
            .removeDuplicates()
            .sink { [unowned self] text in
                viewStore?.send(.textFieldChanged(text))
            }
            .store(in: &cancelBag)
        
        viewStore?.publisher.description
            .assign(to: \.text, on: textField)
            .store(in: &cancelBag)
                    
        viewStore?.publisher.isComplete
            .sink { [unowned self] state in
                button.setImage(UIImage(systemName: state ? "checkmark.square" : "square"), for: .normal)
                textField.textColor = state ? .gray : nil
            }
            .store(in: &cancelBag)
    }
}


