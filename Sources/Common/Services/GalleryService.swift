import Foundation
import UIKit
import Photos

// MARK: - Protocols

protocol GalleryServiceProtocol: AnyObject {
    var handlePhotoLibraryStatus: ((PHAuthorizationStatus) -> Void)? { get set }
    var photosCount: Int { get }
    var photos: [PHAsset] { get }
    func requestPhotoLibraryAccess()
    func fetchPhotos()
    func getImage(at index: Int, completion: @escaping (UIImage?) -> Void)
    func deletePhoto(at index: Int) -> PHAsset
    func deletePhoto(_ photo: PHAsset)
}

// MARK: - Implementation

final class GalleryService: NSObject, GalleryServiceProtocol {

    var handlePhotoLibraryStatus: ((PHAuthorizationStatus) -> Void)?
    var photosCount: Int { photos.count }

    private(set) var photos: [PHAsset] = []
    private let imageManager = PHImageManager.default()

    // MARK: - Init

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    // MARK: - Public

    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.handlePhotoLibraryStatus?(status)
            }
        }
    }

    func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        photos = assets.objects(at: IndexSet(integersIn: 0..<assets.count))
    }

    func getImage(at index: Int, completion: @escaping (UIImage?) -> Void) {
        guard index >= 0, index < photos.count else { return }
        
        let photo = photos[index]
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true

        imageManager.requestImage(
            for: photo,
            targetSize: CGSize(width: 300, height: 450),
            contentMode: .aspectFill,
            options: requestOptions) { image, _ in
                DispatchQueue.main.async {
                    completion(image)
                }
            }
    }

    @discardableResult func deletePhoto(at index: Int) -> PHAsset {
        photos.remove(at: index)
    }

    func deletePhoto(_ photo: PHAsset) {
        guard let index = photos.firstIndex(of: photo) else { return }
        deletePhoto(at: index)
    }
}

// MARK: - PHPhotoLibrary Change Observer

extension GalleryService: PHPhotoLibraryChangeObserver {

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        requestPhotoLibraryAccess()
    }
}
