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
        let vc = UINavigationController(rootViewController: TodosVC(store: Store(initialState: Todos.State()) { Todos() }))
        
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

