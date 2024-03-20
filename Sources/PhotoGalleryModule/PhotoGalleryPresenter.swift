import Foundation
import UIKit

protocol PhotoGalleryPresenterDelegate: AnyObject {
    func presentPhoto(with image: UIImage)
    func updateCounterUI(counter: Int)
    func updateSaveButtonState()
    func updateDeleteButtonState()
    func updateTrashButton(for state: TrashButtonState)
}

enum TrashButtonState {
    case enabled, disabled
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

        photoService.updateSaveButtonHandler = { [weak self] in
            guard let self else { return }
            self.delegate?.updateSaveButtonState()
        }
        
        photoService.updateDeleteButtonHandler = { [weak self] in
            guard let self else { return }
            self.delegate?.updateDeleteButtonState()
        }

        trashService.didUpdateEmptyTrashHandler = { [weak self] state in
            guard let self else { return }
            self.delegate?.updateTrashButton(for: state)
        }

        photoService.deletePhoto()
    }

    func emptyTrashButtonClicked() {
        trashService.emptyTrash()
        trashService.didUpdateCounterHandler = { [weak self] in
            guard let self else { return }
            self.delegate?.updateCounterUI(counter: self.trashService.countPhotos())
        }
    }
}
