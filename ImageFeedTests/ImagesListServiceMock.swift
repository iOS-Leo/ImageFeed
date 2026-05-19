//
//  ImagesListServiceMock.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 19.05.2026.
//


import Foundation
@testable import ImageFeed 
internal import CoreGraphics

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [ImagesListService.Photo] = [
        ImagesListService.Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
    ]
    
    func fetchPhotosNextPage() {
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
    }
}
