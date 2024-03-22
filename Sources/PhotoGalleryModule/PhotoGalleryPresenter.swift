import Foundation
import UIKit

// MARK: - Protocols

protocol PhotoGalleryPresenterInput: AnyObject {
    func viewIsLoaded()
    func saveButtonTapped()
    func emptyTrashButtonTapped()
    func deleteButtonTapped()
}

protocol PhotoGalleryPresenterOutput: AnyObject {
    func presentImage(_ image: UIImage?)
    func updateCounterUI(counter: Int)
    func updateSaveButtonState(isEnabled: Bool)
    func updateDeleteButtonState(isEnabled: Bool)
    func updateTrashButton(isEnabled: Bool)
    func presentDeniedAlert()
}

// MARK: - Implementation

final class PhotoGalleryPresenter: PhotoGalleryPresenterInput {

    weak var output: PhotoGalleryPresenterOutput?

    private let galleryService: GalleryServiceProtocol
    private let trashService: TrashImagesServiceProtocol
    private var currentIndex = 0

    // MARK: - Init

    init(galleryService: GalleryServiceProtocol, trashService: TrashImagesServiceProtocol) {
        self.galleryService = galleryService
        self.trashService = trashService
        configureCompletionHandlers()
    }

    private func configureCompletionHandlers() {
        galleryService.handlePhotoLibraryStatus = { [weak self] status in
            guard let self else { return }
            switch status {
            case .notDetermined:
                break
            case .restricted:
                break
            case .denied:
                output?.presentDeniedAlert()
                output?.updateDeleteButtonState(isEnabled: false)
                output?.updateSaveButtonState(isEnabled: false)
            case .authorized:
                updatePhotos()
            case .limited:
                updatePhotos()
            @unknown default:
                break
            }
        }
    }

    // MARK: - Public

    func viewIsLoaded() {
        galleryService.requestPhotoLibraryAccess()
    }

    func saveButtonTapped() {
        moveToNextPhoto()
    }

    func emptyTrashButtonTapped() {
        trashService.emptyTrash() { [weak self] isSuccess in
            guard let self else { return }
            self.output?.updateCounterUI(counter: self.trashService.trashImagesCount)
            self.output?.updateTrashButton(isEnabled: !isSuccess)
        }
    }

    func deleteButtonTapped() {
        guard galleryService.photosCount > 0 else { return }

        let deletedPhoto = galleryService.deletePhoto(at: currentIndex)
        trashService.addToTrash(image: deletedPhoto)
        output?.updateTrashButton(isEnabled: true)
        output?.updateCounterUI(counter: trashService.trashImagesCount)

        if galleryService.photosCount == 1 {
            output?.updateSaveButtonState(isEnabled: false)
        }

        if galleryService.photosCount == 0 {
            presentEmptyImage()
            output?.updateDeleteButtonState(isEnabled: false)
            return
        }

        currentIndex -= 1
        moveToNextPhoto()
    }

    // MARK: - Private

    private func presentEmptyImage() {
        let image = UIImage(named: "empty_state_icon")
        self.output?.presentImage(image)
    }

    private func moveToNextPhoto() {
        guard galleryService.photosCount > 0 else { return }

        currentIndex += 1

        if currentIndex >= galleryService.photosCount {
            currentIndex = 0
        }

        galleryService.getImage(at: currentIndex) { [weak self] image in
            guard let self else { return }
            output?.presentImage(image)
        }
    }

    private func updatePhotos() {
        galleryService.fetchPhotos()

        if galleryService.photosCount >= 1 {
            galleryService.getImage(at: currentIndex) { [weak self] image in
                guard let self else { return }
                output?.presentImage(image)
                output?.updateDeleteButtonState(isEnabled: galleryService.photosCount >= 1)
                output?.updateSaveButtonState(isEnabled: galleryService.photosCount > 1)
            }
        } else {
            presentEmptyImage()
            output?.updateDeleteButtonState(isEnabled: false)
            output?.updateSaveButtonState(isEnabled: false)
        }
    }
}
