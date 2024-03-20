import UIKit

final class UIBuilder {
    
    var window: UIWindow?
    let photoService = PhotoService()
    let trashService = TrashImagesService()

    func createRootViewController(window: UIWindow) -> UIViewController {
        let photoGalleryViewController = PhotoGalleryViewController()
        let presenter = PhotoGalleryPresenter(photoService: photoService, trashService: trashService)
        presenter.delegate = photoGalleryViewController
        photoGalleryViewController.presenter = presenter
        self.window = window
        return photoGalleryViewController
    }
}
