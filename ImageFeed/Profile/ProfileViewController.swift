import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private var presenter: ProfilePresenterProtocol?
    
    // MARK: - UI Elements
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.image = UIImage(resource: .photoProfile)
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.text = ""
        label.textColor = .ypWhiteIOS
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = ""
        label.textColor = .ypWhiteIOS
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = ""
        label.textColor = .ypWhiteIOS
        return label
    }()
    
    lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "ExitButton")
        button.tintColor = .ypRedIOS
        button.setImage(image, for: .normal)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlackIOS
        setupView()
        setupConstraints()
        
        guard let presenter = presenter else {
            assertionFailure("ProfileViewController: Presenter is not configured!")
            return
        }
        presenter.viewDidLoad()
    }
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
    }
    
    
    
    // MARK: - Actions
    @objc private func logoutTapped() {
        presenter?.didTapLogoutButton()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: loginNameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
        ])
        
    }
}

extension ProfileViewController: ProfileViewOutput {
    
    func showProfile(name: String, login: String, bio: String, avatarURL: URL?) {
        hideLoading()
        
        nameLabel.text = name
        loginNameLabel.text = login
        descriptionLabel.text = bio
        
        if let url = avatarURL {
            avatarImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "photoProfile"),
                options: [.processor(RoundCornerImageProcessor(cornerRadius: 35))]
            )
        } else {
            avatarImageView.image = UIImage(named: "photoProfile")
        }
    }
    
    func showLoading() {
        ShimmerAnimationHelper.shared.addShimmer(to: avatarImageView, cornerRadius: 35)
        ShimmerAnimationHelper.shared.addShimmer(to: nameLabel, cornerRadius: 11.5)
        ShimmerAnimationHelper.shared.addShimmer(to: loginNameLabel, cornerRadius: 6.5)
        ShimmerAnimationHelper.shared.addShimmer(to: descriptionLabel, cornerRadius: 6.5)
    }
    
    func hideLoading() {
        ShimmerAnimationHelper.shared.removeShimmers(from: [
            avatarImageView, nameLabel, loginNameLabel, descriptionLabel
        ])
    }
    
    func presentLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверен, что хочешь выйти?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.presenter?.confirmLogout()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
}

