//
//  ImagesListServiceProtocol.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 24.05.2026.
//

import Foundation

protocol ImagesListServiceProtocol {
    func fetchPhotosNextPage()
    var photos: [Photo] { get }
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}
