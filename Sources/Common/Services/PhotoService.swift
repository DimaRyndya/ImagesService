import Foundation
import UIKit
import Photos

final class PhotoService {

    var images: [PHAsset] = []
    var currentIndex = 0
    var presentImageHandler: ((UIImage?) -> Void)?
    var imageDeleteHandler: ((PHAsset) -> Void)?

    func getPhotos() {
        requestPhotoLibraryAccess()
    }

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
            print("notDetermined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorized:
            fetchPhotos()
        case .limited:
            print("limited")
        @unknown default:
            break
        }
    }

    private func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        images = assets.objects(at: IndexSet(integersIn: currentIndex..<assets.count))

        if !images.isEmpty {
            displayPhoto(at: currentIndex)
        }
    }

    func displayPhoto(at index: Int) {
        guard index >= 0, index < images.count else { return }

        let asset = images[index]
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true

        PHImageManager.default().requestImage(
            for: asset,
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

        if images.isEmpty {
            let image = UIImage(named: "empty_state_icon")
            self.presentImageHandler?(image)
            return
        }

        currentIndex -= 1
        showNextPhoto()
    }
}
