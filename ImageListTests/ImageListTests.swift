

import XCTest
@testable import ImageFeed


final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var photos: [ImagesListService.Photo] = []
    
    var viewDidLoadCalled = false
    var fetchPhotosNextPageCalled = false
    
    func viewDidLoad() { viewDidLoadCalled = true }
    func fetchPhotosNextPage() { fetchPhotosNextPageCalled = true }
    func changeLike(photoId: String, isLiked: Bool, indexPath: IndexPath) {}
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var showLikeErrorCalled = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) { updateTableViewAnimatedCalled = true }
    func updateLike(at indexPath: IndexPath, isLiked: Bool) {}
    func showLikeError() { showLikeErrorCalled = true }
}

final class ImagesListServiceStub: ImagesListServiceProtocol {
    var photos: [ImagesListService.Photo] = []
    func fetchPhotosNextPage() {}
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        viewController.loadViewIfNeeded()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateTableView() {
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(service: ImagesListServiceStub())
        presenter.view = viewSpy
        
        presenter.didUpdatePhotos()
        
        XCTAssertTrue(viewSpy.updateTableViewAnimatedCalled)
    }
    
    func testShowLikeError() {
        let viewSpy = ImagesListViewControllerSpy()
        viewSpy.showLikeError()
        
        XCTAssertTrue(viewSpy.showLikeErrorCalled)
    }
}
