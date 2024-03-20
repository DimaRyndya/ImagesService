import Foundation
import UIKit

protocol PhotoGalleryPresenterDelegate: AnyObject {
    func presentPhoto(with image: UIImage)
}

final class PhotoGalleryPresenter {

    // MARK: - Properties

    let photoService: PhotoService

    weak var delegate: PhotoGalleryPresenterDelegate?

    // MARK: - Init

    init(photoService: PhotoService) {
        self.photoService = photoService
    }

    // MARK: - Public

    func photoImageViewClicked() {
        
    }

    func viewIsLoaded() {
        photoService.getPhotos()
        photoService.imageRequestHandler = { image in
            guard let image else { return }
            self.delegate?.presentPhoto(with: image)
        }
    }

    func saveButtonClicked() {
        photoService.showNextPhoto()
    }
}
