import Foundation
import Photos

final class TrashImagesService {

    // MARK: - Properties

    private(set) var trash: [PHAsset] = []
    
    var trashImagesCount: Int {
        trash.count
    }

    // MARK: - Public

    func addToTrash(image: PHAsset) {
        trash.append(image)
    }

    func emptyTrash(completion: @escaping () -> Void) {
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
                completion()
            }
        }
    }
}
