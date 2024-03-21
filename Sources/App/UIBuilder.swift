import UIKit

final class UIBuilder {
    
    // MARK: - Properties

    var window: UIWindow?
    let photoService = PhotoService()
    let trashService = TrashImagesService()

    // MARK: - Public

    func createRootViewController(window: UIWindow) -> UIViewController {
        let viewController = PhotoGalleryViewController()
        let presenter = PhotoGalleryPresenter(photoService: photoService, trashService: trashService)
        presenter.output = viewController
        viewController.presenter = presenter
        self.window = window
        return viewController
    }
}
