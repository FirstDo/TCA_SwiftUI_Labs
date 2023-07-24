import UIKit
import Combine

import SnapKit
import ComposableArchitecture
import CombineCocoa
import Then

struct EffectLongLiving: ReducerProtocol {
    struct State: Equatable {
        var screenCount = 0
    }
    
    enum Action {
        case task
        case userDidTakeScreenshotNotification
    }
    
    @Dependency(\.screenshots) var screenshots
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .task:
            return .run { send in
                for await _ in await self.screenshots() {
                    await send(.userDidTakeScreenshotNotification)
                }
            }
            
        case .userDidTakeScreenshotNotification:
            state.screenCount += 1
            return .none
        }
    }
}

extension DependencyValues {
    var screenshots: @Sendable () async -> AsyncStream<Void> {
        get { self[ScreenshotsKey.self] }
        set { self[ScreenshotsKey.self] = newValue }
    }
}

private enum ScreenshotsKey: DependencyKey {
    static let liveValue: @Sendable () async -> AsyncStream<Void> = {
        await AsyncStream(
            NotificationCenter.default
                .notifications(named: UIApplication.userDidTakeScreenshotNotification)
                .map { _ in }
        )
    }
}

class EffectLongLivingVC: BaseVC<EffectLongLiving> {
    
    private let label = UILabel().then {
        $0.textColor = .label
    }
    
    private let button = UIButton(type: .roundedRect).then {
        $0.setTitle("Navigate to another screen", for: .normal)
    }
    
    override func setup() {
        view.addSubview(label)
        view.addSubview(button)
        
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        button.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(label.snp.bottom).offset(50)
        }
    }
    
    override func bind() {
        viewStore.publisher.screenCount
            .sink { [unowned self] num in
                label.text = "A screenshot of this screen has been taken \(num) times"
            }
            .store(in: &cancelBag)
        
        button.tapPublisher
            .sink { [unowned self] in
                let vc = UIViewController()
                vc.view.backgroundColor = .white
                navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancelBag)
    }
}
