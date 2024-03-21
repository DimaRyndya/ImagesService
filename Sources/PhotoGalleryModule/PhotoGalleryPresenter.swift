import Foundation
import UIKit

protocol PhotoGalleryPresenterOutput: AnyObject {
    func presentImage(_ image: UIImage)
    func updateCounterUI(counter: Int)
    func updateSaveButtonState(isEnabled: Bool)
    func updateDeleteButtonState(isEnabled: Bool)
    func updateTrashButton(isEnabled: Bool)
    func presentDeniedAlert()
}

final class PhotoGalleryPresenter {

    // MARK: - Properties

    let photoService: PhotoService
    let trashService: TrashImagesService

    weak var output: PhotoGalleryPresenterOutput?

    var currentIndex = 0

    // MARK: - Init

    init(photoService: PhotoService, trashService: TrashImagesService) {
        self.photoService = photoService
        self.trashService = trashService
        configureCompletionHandlers()
    }

    // MARK: - Public

    func viewIsLoaded() {
        photoService.requestPhotoLibraryAccess()
    }

    private func updatePhotos() {
        photoService.fetchPhotos() { [weak self] in
            guard let self else { return }
            if photoService.photos.count > 1 {
                let image = photoService.getImage(at: currentIndex)
                output?.presentImage(image ?? UIImage())
                output?.updateDeleteButtonState(isEnabled: true)
                output?.updateSaveButtonState(isEnabled: true)
            } else if photoService.photos.count == 1 {
                let image = photoService.getImage(at: currentIndex)
                output?.presentImage(image ?? UIImage())
                output?.updateDeleteButtonState(isEnabled: false)
                output?.updateSaveButtonState(isEnabled: true)
            } else {
                presentEmptyImage()
                output?.updateDeleteButtonState(isEnabled: false)
                output?.updateSaveButtonState(isEnabled: false)
            }
        }
    }

    func saveButtonClicked() {
        moveToNextPhoto()
    }

    func emptyTrashButtonClicked() {
        trashService.emptyTrash() { [weak self] in
            guard let self else { return }
            self.output?.updateCounterUI(counter: self.trashService.trashImagesCount)
            self.output?.updateTrashButton(isEnabled: false)
        }
    }

    func deleteButtonClicked() {
        guard !photoService.photos.isEmpty else { return }

        let deletedPhoto = photoService.deletePhoto(at: currentIndex)
        trashService.addToTrash(image: deletedPhoto)
        output?.updateTrashButton(isEnabled: true)
        output?.updateCounterUI(counter: trashService.trashImagesCount)

        if photoService.photos.count == 1 {
            output?.updateSaveButtonState(isEnabled: false)
        }

        if photoService.photos.isEmpty {

            presentEmptyImage()
            output?.updateDeleteButtonState(isEnabled: false)
            return
        }

        currentIndex -= 1
        moveToNextPhoto()
    }

    private func presentEmptyImage() {
        let image = UIImage(named: "empty_state_icon")
        self.output?.presentImage(image ?? UIImage())
    }

    private func moveToNextPhoto() {
        guard !photoService.photos.isEmpty else { return }

        currentIndex += 1
        
        let image: UIImage?

        if currentIndex < photoService.photos.count {
            image = photoService.getImage(at: currentIndex)
        } else {
            currentIndex = 0
            image = photoService.getImage(at: currentIndex)
        }
        output?.presentImage(image ?? UIImage())
    }

    // MARK: - Private

    private func configureCompletionHandlers() {
        photoService.handlePhotoLibraryStatus = { [weak self] status in
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
}
