import Foundation
import Photos

// MARK: - Protocols

protocol TrashImagesServiceProtocol {
    var trashImagesCount: Int { get }
    func addToTrash(image: PHAsset)
    func emptyTrash(completion: @escaping (Bool) -> Void)
}

// MARK: - Implementation

final class TrashImagesService: TrashImagesServiceProtocol {

    var trashImagesCount: Int { trash.count }

    private var trash: [PHAsset] = []

    // MARK: - Public

    func addToTrash(image: PHAsset) {
        trash.append(image)
    }

    func emptyTrash(completion: @escaping (Bool) -> Void) {
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
            DispatchQueue.main.async {
                if success {
                    self?.trash.removeAll()
                }
                completion(success)
            }
        }
    }
}
