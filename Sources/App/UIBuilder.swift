import UIKit

final class UIBuilder {

    let photoService = PhotoService()
    var window: UIWindow?

    func createRootViewController(window: UIWindow) -> UIViewController {
        let photoGalleryViewController = PhotoGalleryViewController()
        let presenter = PhotoGalleryPresenter(photoService: photoService)
        presenter.delegate = photoGalleryViewController
        photoGalleryViewController.presenter = presenter
        self.window = window
        return photoGalleryViewController
    }
}
