import UIKit
import Combine

import ComposableArchitecture
import CombineCocoa

struct Item: Hashable {
    enum ViewType: String, Hashable {
        case basics
        case combiningReducers
        case Bindings
        case OptionalState
        case SharedState
        
        case Effects_Basics
        case Effects_Cancellation
        case Effects_LongLivingEffects
        case Effects_Refreshable
        case Effects_Timers
        case Effects_WebSocket
        
        case LoadThenNavigate
        case ListsOfState
    }

    let type: ViewType
    
    var viewController: UIViewController {
        switch type {
        case .basics:
            return CounterVC(store: Store(
                initialState: Counter.State()) { Counter() }
            )
        case .combiningReducers:
            return TwoCounterVC(store: Store(
                initialState: TwoCounter.State()) { TwoCounter() }
            )
        case .Bindings:
            return BindingsVC(store: Store(
                initialState: Bindings.State()) { Bindings() }
            )
        case .OptionalState:
          return OptionalVC(store: Store(
            initialState: OptionalBasics.State()) { OptionalBasics() }
          )
        case .SharedState:
            return SharedVC(store: Store(
                initialState: SharedState.State()) { SharedState() }
            )
        case .Effects_Basics:
            return EffectsBasicsVC(store: Store(
                initialState: EffectsBasics.State()) { EffectsBasics() }
            )
        case .Effects_Cancellation:
            return EffectCancellactionVC(store: Store(
                initialState: EffectCancellation.State()) { EffectCancellation() }
            )
        case .Effects_LongLivingEffects:
            return EffectLongLivingVC(store: Store(
                initialState: EffectLongLiving.State()) { EffectLongLiving() }
            )
        case .Effects_Refreshable:
            return EffectRefreshableVC(store: Store(
                initialState: EffectRefreshable.State()) { EffectRefreshable() }
            )
        case .Effects_Timers:
            return EffectTimerVC(store: Store(
                initialState: EffectTimer.State()) { EffectTimer() }
            )
        case .Effects_WebSocket:
            return UIViewController()
        case .LoadThenNavigate:
            return LoadAndNavigateVC(store: Store(
                initialState: LoadAndNavigate.State()) { LoadAndNavigate() }
            )
        case .ListsOfState:
            return CounterListVC(store: Store(
                initialState: CounterList.State()) { CounterList() }
            )
        }
    }
}

extension Item {
    static let caseStudyData: [Item] = [
        Item(type: .basics),
        Item(type: .combiningReducers),
        Item(type: .Bindings),
        Item(type: .OptionalState),
        Item(type: .SharedState)
    ]
    
    static let effectsData: [Item] = [
        Item(type: .Effects_Basics),
        Item(type: .Effects_Cancellation),
        Item(type: .Effects_LongLivingEffects),
        Item(type: .Effects_Refreshable),
        Item(type: .Effects_Timers),
        Item(type: .Effects_WebSocket)
    ]
    
    static let navigationData: [Item] = [
        Item(type: .LoadThenNavigate),
        Item(type: .ListsOfState),
    ]
}

class RootVC: UITableViewController {
    private typealias DataSource = UITableViewDiffableDataSource<Int, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item>
    
    private var cancelBag = Set<AnyCancellable>()
    
    private var dataSource: DataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "CaseStudy"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView = UITableView(frame: view.frame, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        bind()
        applySnapshot()
    }
    
    private func bind() {
        tableView.didSelectRowPublisher
            .sink { [unowned self] indexPath in
                let item = dataSource.itemIdentifier(for: indexPath)!
                navigationController?.pushViewController(item.viewController, animated: true)
            }
            .store(in: &cancelBag)
    }
    
    private func applySnapshot() {
        dataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = item.type.rawValue
            return cell
        }
        
        var snapshot = Snapshot()
        snapshot.appendSections([0, 1, 2, 3])
        snapshot.appendItems(Item.caseStudyData, toSection: 0)
        snapshot.appendItems(Item.effectsData, toSection: 1)
        snapshot.appendItems(Item.navigationData, toSection: 2)
        dataSource.apply(snapshot)
    }
}
