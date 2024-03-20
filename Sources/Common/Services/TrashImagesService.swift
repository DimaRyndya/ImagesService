import Foundation
import Photos

final class TrashImagesService {

    var trash: [PHAsset] = []

    func addToTrash(image: PHAsset) {
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
        } completionHandler: { success, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        }
        trash.removeAll()
    }
}
