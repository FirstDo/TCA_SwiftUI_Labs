import UIKit
import Combine

import CombineCocoa
import ComposableArchitecture
import Then
import SnapKit

enum Filter: String, CaseIterable {
    case all
    case active
    case completed
    
    static func convert(_ index: Int) -> Filter {
        switch index {
        case 0:
            return .all
        case 1:
            return .active
        default:
            return .completed
        }
    }
}

struct Todos: ReducerProtocol {
    struct State: Equatable {
        var isEditMode: Bool = false
        var filter: Filter = .all
        var todos: IdentifiedArrayOf<Todo.State> = [
            Todo.State(id: UUID(), description: "1", isComplete: false),
            Todo.State(id: UUID(), description: "2", isComplete: false),
            Todo.State(id: UUID(), description: "3", isComplete: false),
            Todo.State(id: UUID(), description: "4", isComplete: false),
            Todo.State(id: UUID(), description: "5", isComplete: false),
            Todo.State(id: UUID(), description: "6", isComplete: false),
            Todo.State(id: UUID(), description: "7", isComplete: false),
            Todo.State(id: UUID(), description: "8", isComplete: false),
        ]
        
        var filteredTodos: IdentifiedArrayOf<Todo.State> {
            switch filter {
            case .all:
                return todos
            case .active:
                return self.todos.filter { !$0.isComplete }
            case .completed:
                return self.todos.filter(\.isComplete)
            }
        }
    }
    
    enum Action {
        case addTodoButtonTapped
        case clearCompletedButtonTapped
        case delete(IndexPath)
        case editModeChanged
        case filterPicked(Filter)
        case move(Int, Int)
        case sortCompletedTodos
        case todo(id: Todo.State.ID, action: Todo.Action)
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.uuid) var uuid
    private enum CancelID { case todoCompletion }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .addTodoButtonTapped:
                state.todos.insert(Todo.State(id: self.uuid()), at: 0)
                return .none
                
            case .clearCompletedButtonTapped:
                state.todos.removeAll(where: \.isComplete)
                return .none
                
            case .editModeChanged:
                state.isEditMode.toggle()
                return .none
                
            case let .filterPicked(filter):
                state.filter = filter
                return .none
                
            case let .delete(indexPath):
                let target = state.filteredTodos[indexPath.row]
                state.todos.remove(id: target.id)
                return .none
                
            case let .move(source, destination):
                state.todos.swapAt(source, destination)
                
                return .task {
                    try await self.clock.sleep(for: .milliseconds(100))
                    return .sortCompletedTodos
                }
                
            case .sortCompletedTodos:
                state.todos.sort { $1.isComplete && !$0.isComplete }
                return .none
                
            case .todo(id: _, action: .checkBoxToggled):
                return .run { send in
                    try await self.clock.sleep(for: .seconds(1))
                    await send(.sortCompletedTodos, animation: .default)
                }
                .cancellable(id: CancelID.todoCompletion, cancelInFlight: true)
                
            case .todo:
                return .none
            }
        }
        .forEach(\.todos, action: /Action.todo(id:action:)) {
            Todo()
        }
    }
}

final class TodosVC: BaseVC<Todos> {
    
    private var dataSource: DataSource!
    
    private let segmentControl = UISegmentedControl(items: Filter.allCases.map(\.rawValue)).then {
        $0.selectedSegmentIndex = 0
    }
    private let tableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
    }
    private let editButton = UIBarButtonItem(title: "Edit")
    private let clearCompletedButton = UIBarButtonItem(title: "Clear Completed")
    private let addButton = UIBarButtonItem(title: "Add")
    
    private var cellStores = [UUID: Cancellable]()
    
    override func setup() {
        title = "Todos"
        navigationItem.rightBarButtonItems = [addButton, clearCompletedButton, editButton]
        
        view.addSubview(segmentControl)
        view.addSubview(tableView)
        
        segmentControl.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(segmentControl.snp.bottom).offset(10)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        tableView.keyboardDismissMode = .onDrag
        
        dataSource = DataSource(store: store, tableView: tableView) { [unowned self] tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
            
            let todo = viewStore.filteredTodos[indexPath.row]
            
            let cancellable = store.scope(
                state: \.filteredTodos[id: todo.id],
                action: { .todo(id: todo.id, action: $0) }
            ).ifLet {
                cell.bind(store: $0)
            }
            
            cellStores[item] = cancellable
            
            return cell
        }
    }
    
    override func bind() {
        addButton.tapPublisher
            .sink { [unowned self] _ in
                viewStore.send(.addTodoButtonTapped)
            }
            .store(in: &cancelBag)
        
        clearCompletedButton.tapPublisher
            .sink { [unowned self] _ in
                viewStore.send(.clearCompletedButtonTapped)
            }
            .store(in: &cancelBag)
        
        editButton.tapPublisher
            .sink { [unowned self] _ in
                viewStore.send(.editModeChanged)
            }
            .store(in: &cancelBag)
        
        segmentControl.selectedSegmentIndexPublisher
            .map(Filter.convert)
            .sink { [unowned self] in
                viewStore.send(.filterPicked($0))
            }
            .store(in: &cancelBag)
        
        viewStore.publisher.filteredTodos
            .print()
            .sink(receiveValue: applySnapshot)
            .store(in: &cancelBag)
        
        viewStore.publisher.isEditMode
            .assign(to: \.isEditing, on: tableView)
            .store(in: &cancelBag)
    }
    
    private func applySnapshot(todos: IdentifiedArrayOf<Todo.State>) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([0])
        snapshot.appendItems(todos.map(\.id))
        
        dataSource.apply(snapshot)
        dataSource.defaultRowAnimation = .none
    }
}

private final class DataSource: UITableViewDiffableDataSource<Int, UUID> {
    
    private let store: StoreOf<Todos>
    private let viewStore: ViewStoreOf<Todos>
    
    init(
        store: StoreOf<Todos>,
        tableView: UITableView,
        cellProvider: @escaping UITableViewDiffableDataSource<Int, UUID>.CellProvider
    ) {
        self.store = store
        self.viewStore = ViewStore(store)
        super.init(tableView: tableView, cellProvider: cellProvider)
    }
    
    override func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        guard sourceIndexPath.row != destinationIndexPath.row else { return }
        
        viewStore.send(.move(sourceIndexPath.row, destinationIndexPath.row))
    }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {
            guard editingStyle == .delete else { return }
            
            viewStore.send(.delete(indexPath))
        }
}
