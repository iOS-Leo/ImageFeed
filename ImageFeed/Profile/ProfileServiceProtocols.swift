//
//  ProfileServiceProtocols.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 24.05.2026.
//

import Foundation

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
}

protocol LogoutServiceProtocol {
    func logout()
}

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
}

