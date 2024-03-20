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
}
