import UIKit
import SnapKit
import PhotosUI

final class PhotoGalleryViewController: UIViewController {

    // MARK: - UI Elements

    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "test_photo")
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoImageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "bin_icon"), for: .normal)
        button.backgroundColor = .systemRed
        button.clipsToBounds = true
        return button
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "checkmark_icon"), for: .normal)
        button.backgroundColor = .systemMint
        button.clipsToBounds = true
        return button
    }()

    private lazy var trashInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 25
        stackView.backgroundColor = UIColor(red: 101 / 255, green: 99 / 255, blue: 164 / 255, alpha: 0.42)
        stackView.layer.cornerRadius = 24
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    private lazy var emptyTrashButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "empty_trash_icon"), for: .normal)
        button.setTitle("Empty Trash", for: .normal)
        button.setTitleColor(UIColor(red: 160 / 255, green: 168 / 255, blue: 212 / 255, alpha: 1), for: .normal)
        button.backgroundColor = UIColor(red: 78 / 255, green: 86 / 255, blue: 130 / 255, alpha: 1)
        button.layer.cornerRadius = 12
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 8
        button.configuration = configuration
        return button
    }()

    private lazy var imagesCounterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var imagesInTrashLabel: UILabel = {
        let label = UILabel()
        label.text = "images in the trash"
        label.numberOfLines = 2
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCornerRadiusToButtons()
    }

    // MARK: - Private

    private func setupUI() {
        view.backgroundColor = .black
        configureImageView()
        configureButtonsStackView()
        configureTrashInfoStackView()
    }

    private func configureImageView() {
        view.addSubview(photoImageView)
        photoImageView.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            maker.leading.equalToSuperview().offset(32)
            maker.trailing.equalToSuperview().offset(-32)
        }
    }

    private func configureButtonsStackView() {
        photoImageView.addSubview(buttonsStackView)

        buttonsStackView.snp.makeConstraints { maker in
            maker.leading.equalToSuperview().offset(56)
            maker.trailing.equalToSuperview().offset(-56)
            maker.bottom.equalToSuperview().offset(-16)
        }

        buttonsStackView.addArrangedSubview(deleteButton)
        deleteButton.snp.makeConstraints { maker in
            maker.width.height.equalTo(60)
        }

        buttonsStackView.addArrangedSubview(saveButton)
        saveButton.snp.makeConstraints { maker in
            maker.width.height.equalTo(60)
        }
    }

    private func configureTrashInfoStackView() {
        view.addSubview(trashInfoStackView)
        trashInfoStackView.snp.makeConstraints { maker in
            maker.top.equalTo(photoImageView.snp.bottom).offset(64)
            maker.leading.equalToSuperview().offset(32)
            maker.trailing.equalToSuperview().offset(-32)
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
            maker.height.equalTo(72)
        }

        counterLabel.snp.makeConstraints { maker in
            maker.width.equalTo(35)
        }

        imagesInTrashLabel.snp.makeConstraints { maker in
            maker.width.equalTo(65)
        }

        trashInfoStackView.addArrangedSubview(imagesCounterStackView)
        imagesCounterStackView.addArrangedSubview(counterLabel)
        imagesCounterStackView.addArrangedSubview(imagesInTrashLabel)
        trashInfoStackView.addArrangedSubview(emptyTrashButton)
    }

    private func applyCornerRadiusToButtons() {
        deleteButton.layer.cornerRadius = deleteButton.bounds.width / 2
        saveButton.layer.cornerRadius = saveButton.bounds.width / 2
    }

    @objc private func photoImageViewTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let photoPicker = PHPickerViewController(configuration: configuration)
        photoPicker.delegate = self
        present(photoPicker, animated: true)
    }
}

// MARK: - PHPickerViewController Delegate extension

extension PhotoGalleryViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let selectedImage = results.first else { return }

        selectedImage.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self.photoImageView.image = image
                }
            }
        }
        dismiss(animated: true)
    }

}

