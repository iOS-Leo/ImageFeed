//
//  ProfileProtocols.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 24.05.2026.
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
