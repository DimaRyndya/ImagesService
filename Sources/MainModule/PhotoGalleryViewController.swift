import UIKit
import SnapKit

final class PhotoGalleryViewController: UIViewController {

    // MARK: - UI Elements

    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "test_photo")
        return imageView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    // MARK: - Private

    private func setupUI() {
        configureImageView()
    }

    private func configureImageView() {
        view.addSubview(photoImageView)
        photoImageView.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            maker.leading.equalToSuperview().offset(32)
            maker.trailing.bottom.equalToSuperview().offset(-32)
        }
    }
}

