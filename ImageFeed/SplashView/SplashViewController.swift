import UIKit

final class SplashViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "auth_screen_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared

    private var imageView: UIImageView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupUI()

        if let token = storage.token {
            fetchProfile(token: token)
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
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController по идентификатору")
            return
        }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            
            present(authViewController, animated: true)
        }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { return }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case let .success(profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
                
            case let .failure(error):
                print(error)
                break
            }
        }
    }
}

extension SplashViewController {
    
    func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            
            UIBlockingProgressHUD.dismiss()
            
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
            guard let self = self else {return}
            guard let token = self.storage.token else {
                return
            }
            self.fetchProfile(token)
        }
    }
}
