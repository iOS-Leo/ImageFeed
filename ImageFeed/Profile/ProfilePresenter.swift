//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 22.05.2026.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapLogoutButton()
    func confirmLogout() 
}

protocol ProfileViewOutput: AnyObject {
    func showProfile(name: String, login: String, bio: String, avatarURL: URL?)
    func showLoading()
    func hideLoading()
    func presentLogoutAlert()
}

protocol ProfileServiceProtocol {
    var profile: ProfileService.Profile? { get }
}
extension ProfileService: ProfileServiceProtocol {}

protocol LogoutServiceProtocol {
    func logout()
}
extension ProfileLogoutService: LogoutServiceProtocol {}

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
}
extension ProfileImageService: ProfileImageServiceProtocol {}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewOutput?
    
    private let profileService: ProfileServiceProtocol
    private let logoutService: LogoutServiceProtocol
    private let imageService: ProfileImageServiceProtocol
    
    private var imageObserver: NSObjectProtocol?
    
    init(
        view: ProfileViewOutput,
        profileService: ProfileServiceProtocol = ProfileService.shared,
        logoutService: LogoutServiceProtocol = ProfileLogoutService.shared,
        imageService: ProfileImageServiceProtocol = ProfileImageService.shared
    ) {
        self.view = view
        self.profileService = profileService
        self.logoutService = logoutService
        self.imageService = imageService
    }
    
    func viewDidLoad() {
        view?.showLoading()
        
        if let profile = profileService.profile {
            updateView(with: profile)
        } else {
            // Если данных нет, скрываем загрузку (или оставляем, если ждешь асинхронный запрос)
            view?.hideLoading()
        }
        setupImageObserver()
    }
    
    func didTapLogoutButton() {
        view?.presentLogoutAlert()
    }
    
    func confirmLogout() {
        logoutService.logout()
    }
    
    deinit {
        if let observer = imageObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func updateView(with profile: ProfileService.Profile) {
        let avatarURL = imageService.avatarURL.flatMap { URL(string: $0) }
        view?.showProfile(
            name: profile.name,
            login: profile.loginName,
            bio: profile.bio ?? "",
            avatarURL: avatarURL
        )
    }
    
    private func setupImageObserver() {
        imageObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, let profile = self.profileService.profile else { return }
            self.updateView(with: profile)
        }
    }
    
    
}
