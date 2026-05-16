import UIKit

final class SplashViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "auth_screen_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared
    private var isFirstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlackIOS
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirstAppear else { return }
        isFirstAppear = false
        
        if let token = storage.token {
            fetchProfile(token)
        } else {
            showAuthController()
        }
    }
    
    private func setupUI() {
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showAuthController() {
        let authViewController = AuthViewController()
        let navigationController = UINavigationController(rootViewController: authViewController)
        
        navigationController.modalPresentationStyle = .fullScreen
        authViewController.delegate = self
        
        present(navigationController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow })
        else { return }
        
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    
    func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                print("SplashViewController: Error fetching profile: \(error)")
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true){[weak self] in
            guard let self = self,
                  let token = self.storage.token else {
                return
            }
            self.fetchProfile(token)
        }
    }
}
