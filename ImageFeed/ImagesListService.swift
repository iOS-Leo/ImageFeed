//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 12.05.2026.
//

import UIKit



final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    private init() {}
    private let urlSession = URLSession.shared
    private let storage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    private(set) var photos: [Photo] = []
    
    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: Date?
        let welcomeDescription: String?
        let thumbImageURL: String
        let largeImageURL: String
        let isLiked: Bool
    }

    struct PhotoResult: Decodable {
        let id: String
        let width: Int
        let height: Int
        let createdAt: String?
        let description: String?
        let likedByUser: Bool
        let urls: UrlsResult
        
        enum CodingKeys: String, CodingKey {
                case id, width, height, description, urls
                case createdAt = "created_at"
                case likedByUser = "liked_by_user"
            }
    }

    struct UrlsResult: Decodable {
        let thumb: String
        let full: String
    }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil { return }
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService]: Ошибка — токен не найден в Keychain")
            return
        }
        
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let photoResults):
                
                let newPhotos = photoResults.map { photoResult in
                    Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: ISO8601DateFormatter().date(from: photoResult.createdAt ?? ""),
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls.thumb,
                        largeImageURL: photoResult.urls.full,
                        isLiked: photoResult.likedByUser
                    )
                }
                
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    self.task = nil
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
                
            case .failure(let error):
                self.task = nil 
                print("[ImagesListService]: Error loading page \(nextPage) - \(error)")
            }
        }
        
        self.task = task
        task.resume()
    }
}
