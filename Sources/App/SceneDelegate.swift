import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let builder = UIBuilder()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = builder.createRootViewController(window: window)
        window.makeKeyAndVisible()
    }
}

