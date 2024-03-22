import UIKit
import SnapKit

final class PhotoGalleryViewController: UIViewController {

    var presenter: PhotoGalleryPresenterInput!

    // MARK: - UI Elements

    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "empty_state_icon")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
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
        button.layer.cornerRadius = 30
        button.backgroundColor = .systemRed
        button.clipsToBounds = true
        return button
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "checkmark_icon"), for: .normal)
        button.layer.cornerRadius = 30
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
        button.isEnabled = false
        button.setImage(UIImage(named: "empty_trash_icon"), for: .normal)
        button.alpha = 0.7
        button.setTitle("Empty Trash", for: .normal)
        button.setTitleColor(.trashButtonTitle, for: .normal)
        button.tintColor = .trashButtonTitle
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
        presenter.viewIsLoaded()
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
        configureSaveButtonAction()
        configureDeleteButtonAction()
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

        configureEmptyTrashButtonAction()

        trashInfoStackView.addArrangedSubview(imagesCounterStackView)
        imagesCounterStackView.addArrangedSubview(counterLabel)
        imagesCounterStackView.addArrangedSubview(imagesInTrashLabel)
        trashInfoStackView.addArrangedSubview(emptyTrashButton)
    }

    // MARK: - Buttons action configuration

    private func configureSaveButtonAction() {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.presenter.saveButtonTapped()
        }
        saveButton.addAction(action, for: .primaryActionTriggered)
    }

    private func configureDeleteButtonAction() {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.presenter.deleteButtonTapped()
        }
        deleteButton.addAction(action, for: .primaryActionTriggered)
    }

    private func configureEmptyTrashButtonAction() {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.presenter.emptyTrashButtonTapped()
        }
        emptyTrashButton.addAction(action, for: .primaryActionTriggered)
    }
}

// MARK: - PhotoGalleryPresenter Output

extension PhotoGalleryViewController: PhotoGalleryPresenterOutput {

    func presentDeniedAlert() {
        let alert = UIAlertController(
            title: "Access denied",
            message: "This app requires access to Photo Library in order to manage photos. Please go to Setting and change access.",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction =  UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    func presentImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.photoImageView.image = image
        }
    }

    func updateCounterUI(counter: Int) {
        DispatchQueue.main.async {
            self.counterLabel.text = "\(counter)"
        }
    }

    func updateSaveButtonState(isEnabled: Bool) {
        DispatchQueue.main.async {
            self.saveButton.isEnabled = isEnabled
            self.saveButton.backgroundColor = isEnabled ? .systemMint : .systemMint.withAlphaComponent(0.5)
        }
    }

    func updateDeleteButtonState(isEnabled: Bool) {
        DispatchQueue.main.async {
            self.deleteButton.isEnabled = isEnabled
            self.deleteButton.backgroundColor = isEnabled ? .systemRed: .systemRed.withAlphaComponent(0.5)
        }
    }

    func updateTrashButton(isEnabled: Bool) {
        DispatchQueue.main.async {
            self.emptyTrashButton.isEnabled = isEnabled
            self.emptyTrashButton.alpha = isEnabled ? 1 : 0.7
        }
    }
}
