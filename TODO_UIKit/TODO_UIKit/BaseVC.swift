import UIKit
import Combine

import ComposableArchitecture
import SnapKit

class BaseVC<R: Reducer>: UIViewController where R.State: Equatable  {
    
    var store: StoreOf<R>
    var viewStore: ViewStoreOf<R>
    var cancelBag = Set<AnyCancellable>()
    
    init(store: StoreOf<R>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
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
