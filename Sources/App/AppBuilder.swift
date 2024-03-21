import UIKit

final class AppBuilder {

    var window: UIWindow?
    let galleryService = GalleryService()
    let trashService = TrashImagesService()

    func createRootViewController(window: UIWindow) -> UIViewController {
        let viewController = PhotoGalleryViewController()
        let presenter = PhotoGalleryPresenter(galleryService: galleryService, trashService: trashService)
        presenter.output = viewController
        viewController.presenter = presenter
        self.window = window
        return viewController
    }
}
