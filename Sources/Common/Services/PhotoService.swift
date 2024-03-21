import Foundation
import UIKit
import Photos

final class PhotoService: NSObject {

    // MARK: - Properties

    private(set) var images: [PHAsset] = []

    
    var currentIndex = 0
    var presentImageHandler: ((UIImage?) -> Void)?
    var imageDeleteHandler: ((PHAsset) -> Void)?
    var updateSaveButtonHandler: ((SaveButtonState) -> Void)?
    var updateDeleteButtonHandler: ((DeleteButtonState) -> Void)?
    var deniedAlertHandler: (() -> Void)?
    var emptyStateHandler: (() -> Void)?

    // MARK: - Public

    func getPhotos() {
        requestPhotoLibraryAccess()
        PHPhotoLibrary.shared().register(self)
    }

    // MARK: - Private

    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.handlePhotoLibraryStatus(for: status)
            }
        }
    }

    private func handlePhotoLibraryStatus(for status: PHAuthorizationStatus) {
        switch status {
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            deniedAlertHandler?()
            updateDeleteButtonHandler?(.disabled)
            updateSaveButtonHandler?(.disabled)
        case .authorized:
            fetchPhotos()
        case .limited:
            fetchPhotos()
        @unknown default:
            break
        }
    }

    private func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        images = assets.objects(at: IndexSet(integersIn: 0..<assets.count))

        if images.count > 1 {
            displayPhoto(at: currentIndex)
            updateDeleteButtonHandler?(.enabled)
            updateSaveButtonHandler?(.enabled)
        } else if images.count == 1 {
            displayPhoto(at: currentIndex)
            updateSaveButtonHandler?(.disabled)
            updateDeleteButtonHandler?(.enabled)
        } else {
            let image = UIImage(named: "empty_state_icon")
            presentImageHandler?(image)
            updateDeleteButtonHandler?(.disabled)
            updateSaveButtonHandler?(.disabled)
        }
    }

    func displayPhoto(at index: Int) {
        guard index >= 0, index < images.count else { return }

        let images = images[index]
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true

        PHImageManager.default().requestImage(
            for: images,
            targetSize: CGSize(width: 300, height: 450),
            contentMode: .aspectFill,
            options: requestOptions) { image, _ in
                DispatchQueue.main.async {
                    self.presentImageHandler?(image)
                }
            }
    }

    func showNextPhoto() {
        guard !images.isEmpty else { return }

        currentIndex += 1
        if currentIndex < images.count {
            displayPhoto(at: currentIndex)
        } else {
            currentIndex = 0
            displayPhoto(at: currentIndex)
        }
    }

    func deletePhoto() {
        guard !images.isEmpty else { return }

        let image = images[currentIndex]
        self.imageDeleteHandler?(image)
        images.remove(at: currentIndex)

        if images.count == 1 {
            updateSaveButtonHandler?(.disabled)
        }

        if images.isEmpty {
            let image = UIImage(named: "empty_state_icon")
            presentImageHandler?(image)
            updateDeleteButtonHandler?(.disabled)
            return
        }

        currentIndex -= 1
        showNextPhoto()
    }
}

// MARK: - PHPhotoLibrary Change Observer

extension PhotoService: PHPhotoLibraryChangeObserver {

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        requestPhotoLibraryAccess()
    }
}
