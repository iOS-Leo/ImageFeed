//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 21.05.2026.
//

import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private(set) var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private let imagesListService: ImagesListServiceProtocol
    
    init(service: ImagesListServiceProtocol = ImagesListService.shared) {
            self.imagesListService = service
        }
    
    func viewDidLoad() {
        setupObserver()
        fetchPhotosNextPage()
    }
    
    deinit {
            if let observer = imagesListServiceObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    
    private func setupObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.didUpdatePhotos()
        }
    }
    
    func didUpdatePhotos() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func changeLike(photoId: String, isLiked: Bool, indexPath: IndexPath) {
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photoId, isLike: isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                self.view?.updateLike(at: indexPath, isLiked: !isLiked)
            case .failure:
                self.view?.showLikeError()
            }
        }
    }
}
