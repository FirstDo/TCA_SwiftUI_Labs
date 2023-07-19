import UIKit

import CombineCocoa
import ComposableArchitecture
import Then
import SnapKit

struct EffectRefreshable: ReducerProtocol {
    struct State: Equatable {
        var counter = Counter.State()
        var fact: String?
    }
    
    enum Action {
        case cancelButtonTapped
        case factResponse(TaskResult<String>)
        case refresh
        case counter(Counter.Action)
    }
    
    private enum CancelID { case factRequest }
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.counter, action: /Action.counter) {
            Counter()
        }
        
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .cancel(id: CancelID.factRequest)
                
            case .factResponse(.failure):
                return .none
                
            case let .factResponse(.success(fact)):
                state.fact = fact
                return .none
                
            case .refresh:
                state.fact = nil
                return .run { [counter = state.counter] send in
                    await send(
                        .factResponse(TaskResult { try await NetworkManager().fetch(number: counter.count)})
                    )
                }
                .cancellable(id: CancelID.factRequest)
                
            case .counter:
                return .none
            }
        }
    }
}

final class EffectRefreshableVC: BaseVC<EffectRefreshable> {
    
    private let refreshControl = UIRefreshControl().then {
        $0.endRefreshing()
    }
    
    private let tableview = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.register(CounterCell.self, forCellReuseIdentifier: "cell")
        $0.register(TextCell.self, forCellReuseIdentifier: "text")
        $0.rowHeight = 100
    }
    
    override func setup() {
        view.addSubview(tableview)
        tableview.dataSource = self
        tableview.refreshControl = refreshControl
        tableview.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func bind() {
        refreshControl.isRefreshingPublisher
            .dropFirst()
            .sink { [unowned self] state in
                Task {
                    await viewStore.send(.refresh).finish()
                    refreshControl.endRefreshing()
                }
            }
            .store(in: &cancelBag)
    }
}

extension EffectRefreshableVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CounterCell
            cell.setup(store: store.scope(state: \.counter, action: EffectRefreshable.Action.counter))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextCell
            
            viewStore.publisher.fact
                .assign(to: \.text, on: cell.titleLabel)
                .store(in: &cancelBag)
            
            cell.cancelButton.tapPublisher
                .sink { [unowned self] in
                    viewStore.send(.cancelButtonTapped)
                }
                .store(in: &cancelBag)
            
            return cell
        }
    }
}

fileprivate class CounterCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(store: StoreOf<Counter>) {
        let counterView = CounterView(store: store)
        contentView.addSubview(counterView)
        counterView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

fileprivate class TextCell: UITableViewCell {
    
    let cancelButton = UIButton(type: .roundedRect).then {
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(.label, for: .normal)
    }
    
    let titleLabel = UILabel().then {
        $0.textColor = .label
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let hstack = UIStackView(arrangedSubviews: [cancelButton, titleLabel])
        contentView.addSubview(hstack)
        hstack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
