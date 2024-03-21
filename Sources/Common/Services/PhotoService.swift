import Foundation
import UIKit
import Photos

final class PhotoService: NSObject {

    // MARK: - Properties

    private(set) var photos: [PHAsset] = []
    var images: [UIImage] = []
    var handlePhotoLibraryStatus: ((PHAuthorizationStatus) -> Void)?
    private let dispatchGroup = DispatchGroup()

    // MARK: - Public

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    // MARK: - Private

    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.handlePhotoLibraryStatus?(status)

            }
        }
    }

    func fetchPhotos(completion: @escaping () -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        photos = assets.objects(at: IndexSet(integersIn: 0..<assets.count))

        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true

        dispatchGroup.notify(queue: .main) {
            print("Notify")
            completion()
        }

        for photo in photos {
            dispatchGroup.enter()
            print("Enter")
            PHImageManager.default().requestImage(
                for: photo,
                targetSize: CGSize(width: 300, height: 450),
                contentMode: .aspectFill,
                options: requestOptions) { [weak self] image, _ in
                    DispatchQueue.main.async {
                        guard let image = image else { return }
                        self?.images.append(image)
                        self?.dispatchGroup.leave()
                        print("Leave")
                    }
                }
        }
    }

    func getImage(at index: Int) -> UIImage? {
        guard index >= 0, index < images.count else { return nil }
        return images[index]
    }

    func deletePhoto(at index: Int) -> PHAsset {
        images.remove(at: index)
        return photos.remove(at: index)

    }
}

// MARK: - PHPhotoLibrary Change Observer

extension PhotoService: PHPhotoLibraryChangeObserver {

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        requestPhotoLibraryAccess()
    }
}
