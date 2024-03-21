import Foundation
import UIKit

protocol PhotoGalleryPresenterOutput: AnyObject {
    func presentPhoto(with image: UIImage)
    func updateCounterUI(counter: Int)
    func updateSaveButtonState(for state: SaveButtonState)
    func updateDeleteButtonState(for state: DeleteButtonState)
    func updateTrashButton(for state: TrashButtonState)
    func presentDeniedAlert()
}

enum TrashButtonState {
    case enabled, disabled
}

enum SaveButtonState {
    case enabled, disabled
}

enum DeleteButtonState {
    case enabled, disabled
}

final class PhotoGalleryPresenter {

    // MARK: - Properties

    let photoService: PhotoService
    let trashService: TrashImagesService

    weak var output: PhotoGalleryPresenterOutput?

    // MARK: - Init

    init(photoService: PhotoService, trashService: TrashImagesService) {
        self.photoService = photoService
        self.trashService = trashService
        configureCompletionHandlers()
    }

    // MARK: - Public

    func viewIsLoaded() {
        photoService.getPhotos()
    }

    func saveButtonClicked() {
        photoService.showNextPhoto()
    }

    func deleteButtonClicked() {
        photoService.deletePhoto()
    }

    func emptyTrashButtonClicked() {
        trashService.emptyTrash()
    }

    // MARK: - Private

    private func configureCompletionHandlers() {
        self.photoService.deniedAlertHandler = { [weak self] in
            guard let self else { return }
            self.output?.presentDeniedAlert()
        }

        self.photoService.imageDeleteHandler = { [weak self] image in
            guard let self else { return }

            self.trashService.addToTrash(image: image)
            self.output?.updateCounterUI(counter: self.trashService.countPhotos())
        }

        self.photoService.updateSaveButtonHandler = { [weak self] state in
            guard let self else { return }
            self.output?.updateSaveButtonState(for: state)
        }

        self.photoService.updateDeleteButtonHandler = { [weak self] state in
            guard let self else { return }
            self.output?.updateDeleteButtonState(for: state)
        }

        self.trashService.didUpdateEmptyTrashHandler = { [weak self] state in
            guard let self else { return }
            self.output?.updateTrashButton(for: state)
        }

        self.photoService.presentImageHandler = { image in
            guard let image else { return }
            self.output?.presentPhoto(with: image)
        }

        trashService.didUpdateCounterHandler = { [weak self] in
            guard let self else { return }
            self.output?.updateCounterUI(counter: self.trashService.countPhotos())
        }
    }
}
