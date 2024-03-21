import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let appBuilder = AppBuilder()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = appBuilder.createRootViewController(window: window)
        window.makeKeyAndVisible()
    }
}

