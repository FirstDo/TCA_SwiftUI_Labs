import UIKit

import CombineCocoa
import ComposableArchitecture
import Then
import SnapKit

struct CounterList: Reducer {
    struct State: Equatable {
        var counters: IdentifiedArrayOf<Counter.State> = [
            Counter.State(),
            Counter.State(),
            Counter.State()
        ]
    }
    
    enum Action {
        case counter(id: Counter.State.ID, action: Counter.Action)
    }
    
    var body: some Reducer<State, Action> {
        EmptyReducer()
            .forEach(\.counters, action: /Action.counter) {
                Counter()
            }
    }
}

final class CounterListVC: BaseVC<CounterList> {
    
    private let tableview = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func setup() {
        title = "Lists"
        
        view.addSubview(tableview)
        tableview.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableview.dataSource = self
    }
    
    override func bind() {
        viewStore.publisher.counters
            .sink { [unowned self] _ in
                tableview.reloadData()
            }
            .store(in: &cancelBag)
        
        tableview.didSelectRowPublisher
            .map(\.row)
            .sink { [unowned self] row in
                let counter = viewStore.counters[row]
                
                navigationController?.pushViewController(
                    CounterVC(store: store.scope(
                        state: \.counters[row],
                        action: { .counter(id: counter.id, action: $0) }
                    )),
                    animated: true
                )
            }
            .store(in: &cancelBag)
    }
}

extension CounterListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewStore.counters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "\(viewStore.counters[indexPath.row].count)"
        return cell
    }
}

