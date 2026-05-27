//
//  ImagesListProtocols.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 24.05.2026.
//

import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLiked: Bool, indexPath: IndexPath)
}

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func updateLike(at indexPath: IndexPath, isLiked: Bool)
    func showLikeError()
}
