import UIKit
import SnapKit

final class PhotoGalleryViewController: UIViewController {

    // MARK: - Properties

    var presenter: PhotoGalleryPresenter!

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
        button.isEnabled = false
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
        presenter.viewIsLoaded()
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

    private func applyCornerRadiusToButtons() {
        deleteButton.layer.cornerRadius = deleteButton.bounds.width / 2
        saveButton.layer.cornerRadius = saveButton.bounds.width / 2
    }

    // MARK: - Buttons action configuration

    private func configureSaveButtonAction() {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.saveButtonTapped()
        }
        saveButton.addAction(action, for: .primaryActionTriggered)
    }

    private func saveButtonTapped() {
        presenter.saveButtonClicked()
    }

    private func configureDeleteButtonAction() {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.deleteButtonTapped()
        }
        deleteButton.addAction(action, for: .primaryActionTriggered)
    }

    private func deleteButtonTapped() {
        presenter.deleteButtonClicked()
    }

    private func configureEmptyTrashButtonAction() {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.emptyTrashButtonTapped()
        }
        emptyTrashButton.addAction(action, for: .primaryActionTriggered)
    }

    private func emptyTrashButtonTapped() {
        presenter.emptyTrashButtonClicked()
    }
}

// MARK: - PhotoGalleryPresenter Delegate

extension PhotoGalleryViewController: PhotoGalleryPresenterDelegate {

    func presentPhoto(with image: UIImage) {
        DispatchQueue.main.async {
            self.photoImageView.image = image
        }
    }

    func updateCounterUI(counter: Int) {
        DispatchQueue.main.async {
            self.counterLabel.text = "\(counter)"
        }
    }

    func updateSaveButtonState() {
        saveButton.isEnabled = false
    }

    func updateDeleteButtonState() {
        deleteButton.isEnabled = false
    }

    func updateTrashButton(for state: TrashButtonState) {
        DispatchQueue.main.async {
            switch state {
            case .enabled:
                self.emptyTrashButton.isEnabled = true
            case .disabled:
                self.emptyTrashButton.isEnabled = false
            }

        }
    }
}

