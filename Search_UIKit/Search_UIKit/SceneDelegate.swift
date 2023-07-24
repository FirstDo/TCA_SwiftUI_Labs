import UIKit
import SwiftUI

import ComposableArchitecture

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let vc = UINavigationController(rootViewController: SearchVC(store: Store(initialState: Search.State(), reducer: Search())))
        
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

