import Foundation
import Photos

final class TrashImagesService {

    // MARK: - Properties

    private(set) var trash: [PHAsset] = []
    var didUpdateCounterHandler: (() -> Void)?
    var didUpdateEmptyTrashHandler: ((TrashButtonState) -> Void)?

    // MARK: - Public

    func addToTrash(image: PHAsset) {
        didUpdateEmptyTrashHandler?(.enabled)
        trash.append(image)
    }

    func countPhotos() -> Int {
        trash.count
    }

    func emptyTrash() {
        let library = PHPhotoLibrary.shared()
        var photosToDelete: [PHAsset] = []

        for photo in trash {
            let localIdentifier = photo.localIdentifier
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
            if let imageToDelete = fetchResult.firstObject {
                photosToDelete.append(imageToDelete)
            }
        }

        library.performChanges {
            PHAssetChangeRequest.deleteAssets(photosToDelete as NSFastEnumeration)
        } completionHandler: { [weak self] success, _ in

            if success {
                self?.trash.removeAll()
                self?.didUpdateCounterHandler?()
                self?.didUpdateEmptyTrashHandler?(.disabled)
            }
        }
    }
}
