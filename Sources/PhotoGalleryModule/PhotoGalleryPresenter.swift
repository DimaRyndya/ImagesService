import Foundation
import UIKit

protocol PhotoGalleryPresenterDelegate: AnyObject {
    func presentPhoto(with image: UIImage)
    func updateCounterUI(counter: Int)
}

final class PhotoGalleryPresenter {

    // MARK: - Properties

    let photoService: PhotoService
    let trashService: TrashImagesService

    weak var delegate: PhotoGalleryPresenterDelegate?

    // MARK: - Init

    init(photoService: PhotoService, trashService: TrashImagesService) {
        self.photoService = photoService
        self.trashService = trashService
    }

    // MARK: - Public

    func viewIsLoaded() {
        photoService.getPhotos()
        photoService.presentImageHandler = { image in
            guard let image else { return }
            self.delegate?.presentPhoto(with: image)
        }
    }

    func saveButtonClicked() {
        photoService.showNextPhoto()
    }

    func deleteButtonClicked() {
        photoService.imageDeleteHandler = { [weak self] image in
            guard let self else { return }

            self.trashService.addToTrash(image: image)
            self.delegate?.updateCounterUI(counter: self.trashService.countPhotos())
        }
        photoService.deletePhoto()
    }

    func emptyTrashButtonClicked() {
        trashService.emptyTrash()
        delegate?.updateCounterUI(counter: trashService.countPhotos())
    }
}
