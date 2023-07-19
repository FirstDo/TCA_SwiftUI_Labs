import UIKit
import Combine

import ComposableArchitecture
import SnapKit

class BaseVC<Reducer: ReducerProtocol>: UIViewController where Reducer.State: Equatable  {
    
    var store: StoreOf<Reducer>
    var viewStore: ViewStoreOf<Reducer>
    var cancelBag = Set<AnyCancellable>()
    
    init(store: StoreOf<Reducer>) {
        self.store = store
        self.viewStore = ViewStore(store)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable) required init?(coder: NSCoder) {
      fatalError("Not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setup()
        bind()
    }
    
    func setup() {
        
    }
    
    func bind() {
        
    }
}
